global with sharing class TAG_ActivityTimelineModel implements Comparable {

	@AuraEnabled public TAG_ActivityTimeline__mdt config { get; set; }

	@AuraEnabled public Theme theme { get; set; }
	@AuraEnabled public Record record { get; set; }

	public Boolean descending = true;

	public class Theme {
		@AuraEnabled public String icon;
		@AuraEnabled public String sldsTimelineItemColor;
	}

	public class Record {
		@AuraEnabled public Id recordId;
		@AuraEnabled public String sObjectKind;
		@AuraEnabled public String type;
		@AuraEnabled public String title;
		@AuraEnabled public Datetime dateValueDb;
		@AuraEnabled public String dateValue;

		@AuraEnabled public String assignee;
		@AuraEnabled public Id assigneeId;
		@AuraEnabled public String relatedUser;
		@AuraEnabled public Id relatedUserId;
		@AuraEnabled public String subtitle;

		@AuraEnabled public Boolean overdue;
		@AuraEnabled public Boolean lastElement;
	}

	// sorting algorithm
	global Integer compareTo( Object compareTo ) {
		TAG_ActivityTimelineModel compare = (TAG_ActivityTimelineModel) compareTo;
		if ( record.dateValueDb == compare.record.dateValueDb ) { return 0; }
		if ( descending && record.dateValueDb < compare.record.dateValueDb ) { return 1; } // sort descending, newest first
		if ( !descending && record.dateValueDb > compare.record.dateValueDb ) { return 1; } // sort ascending, oldest first (technically, record in 2 days is "older" than one in 4 days)

		return -1;
	}


	public TAG_ActivityTimelineModel( TAG_ActivityTimeline__mdt config, SObject sObj, String lang ) {

		this.config = config;

		Theme theme = new Theme();
		Record record = new Record();

		record.recordId = sObj.Id;

		record.sObjectKind = config.SObjectChild__c;
		record.type = config.SObjectTypeValue__c;
		record.title = (String) sObj.get( config.SObjectTitle__c );
		record.dateValueDb = (Datetime) sObj.get( config.SObjectDateField__c );

		theme.icon = config.SLDS_Icon__c;
		theme.sldsTimelineItemColor = config.SLDS_Timeline_Color__c;

		record.overdue = false;
		if ( record.sObjectKind == 'Task' ) {

			if ( sObj.get( 'Status' ) != 'Completed' && record.dateValueDb < Date.today() ) {
				record.overdue = true;
			}
		}

		if ( record.dateValueDb < DateTime.now() && !record.overdue ) {
			record.subtitle = lang == 'Norsk' ? config.SubtitlePastNorwegian__c : config.SubtitlePastEnglish__c;
		} else {
			record.subtitle = lang == 'Norsk' ? config.SubtitleFutureNorwegian__c : config.SubtitleFutureEnglish__c;
		}

		if ( config.SObjectAssigneeId__c != null ) {
			record.assigneeId = (Id) sObj.get( config.SObjectAssigneeId__c );
			record.assignee = getOwnerName( record.assigneeId );
			if ( record.assigneeId == UserInfo.getUserId() ) {
				record.assigneeId = null;
			}

		} if ( config.SObjectRelatedUserId__c != null ) {
			record.relatedUserId = (Id) sObj.get( config.SObjectRelatedUserId__c );
			record.relatedUser = getContactName( record.relatedUserId, record.sObjectKind, record.type );
			if ( record.relatedUser != null ) {
				record.subtitle += lang == 'Norsk' ? ' ' + returnValueIfNotNull( config.SubtitleRelatedUserPrepositionNor__c ) : ' ' + returnValueIfNotNull( config.SubtitleRelatedUserPrepositionEng__c );
			}
		}


		this.theme = theme;
		this.record = record;
	}



	public static String getOwnerName( Id ownerId ) {
		if ( ownerId == UserInfo.getUserId() ) {
			return Label.ActTime_You;
		} else {
			List<User> u = [SELECT Name FROM User WHERE Id = : ownerId LIMIT 1];
			if ( !u.isEmpty() ) { return u[0].Name; }
		}

		return Label.ActTime_Unknown;
	}

	public static String getContactName( Id contactId, String sObjectType, String type ) {

		List<Contact> u = [SELECT Name FROM Contact WHERE Id = : contactId LIMIT 1];
		if ( !u.isEmpty() ) { return u[0].Name; }
		if ( sObjectType == 'Task' && type == 'Call' ) { return Label.ActTime_Unknown.toLowerCase(); }

		return null;
	}

	public static String returnValueIfNotNull( String input ) {
		return input != null ? input : '';
	}
}




