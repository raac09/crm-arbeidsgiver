const fs = require("fs");
const tasksFraArena = require("../../tmp/AKTIVITETER");
const virksomheter = require("../../dummy-data/tag/Accounts-B");
const TemaMapping = require("./TemaMapping");
const TypeMapping = require("./TypeMapping");
const accountRefs = [];
virksomheter.records.forEach(v => {
  //const key = v.INT_Ident__c;
  accountRefs.push(v.attributes.referenceId);
});

const allRecords = tasksFraArena.map(task => {
  const accountRef = accountRefs[Math.floor(Math.random() * accountRefs.length)];
  return {
    attributes: {
      type: "Task",
      referenceId: "ArenaTask" + task.AKTIVITET_ID
    },
    ActivityDate: task.DATO_FRA.substring(0, 10),
    Priority: "Normal",
    Status: "Completed",
    Subject: task.AKTIVITETTYPENAVN,
    Description: task.BESKRIVELSE,
    Type: TypeMapping[task.AKTIVITETKODE],
    TAG_ActivityType__c: TemaMapping[task.AKTIVITETKODE],
    TaskSubtype: "Task",
    WhatId: "@" + accountRef
  };
});
const records = {
  records: []
};
let fileNumber = 1;
allRecords.forEach((record, index) => {
  records.records.push(record);
  if (records.records.length === 200 || allRecords.length === (index + 1)) {
    const filename = "TasksArena-" + fileNumber + ".generated.json";
    fs.writeFileSync(filename, JSON.stringify(records));
    records.records = [];
    fileNumber++;
  }
});


//console.log(records);