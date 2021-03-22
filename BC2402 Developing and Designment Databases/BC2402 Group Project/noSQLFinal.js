//1.  Generate a list of unique locations (countries) in Asia
db.owidnested.aggregate([
 {$match:{"continent":"Asia"}},
 {$group:{_id: "$location"}},
 {$sort:{_id:1}}
])
//47 Docs

//2. Generate a list of unique locations (countries) in Asia and Europe, with more than 10 total cases on 2020-04-01
db.owidnested.aggregate([
   {$match:{$or:[{continent:"Asia"},{continent:"Europe"}]}},
    {$match:{'Cases.total_cases':{$gt:10}}},
    {$match:{date:ISODate("2020-04-01T00:00:00+08:00")}},
    {$project:{_id:0,location:1,"total_cases":"$Cases.total_cases"}}
    ])
//89 Docs

//3.Generate a list of unique locations (countries) in Africa, with less than 10,000 total cases between 2020-04-01 and 2020-04-20 (inclusive of the start date and end date)
db.owidnested.aggregate([
    {$match:{continent:"Africa"}},
    {$match:{'Cases.total_cases':{$lt:10000}}},
    {$match:{date:{
        $gte: ISODate("2020-04-01T00:00:00.000+08:00"),
        $lte: ISODate("2020-04-20T00:00:00.000+08:00")
    }}},
     { $group: {
        _id:"location",
        location: {$addToSet: "$location"}}},
    {$unwind:"$location"}
    {$sort:{location:1}}
    {$project:{_id:0,location:1}},
    ])
//52 Docs

//4.  Generate a list of unique locations (countries) without any data on total tests
db.owidnested.aggregate([
    {$unwind:"$Tests"},
    {$group : { _id :"$location" , totalTests: {$sum:"$Tests.total_tests"}}},
    {$match : {"totalTests":0}},
    {$sort: {_id:1}}
    ])
// 122 Docs

// 5. Conduct trend analysis, i.e., for each month, compute the total number of new cases globally.
db.owidnested.aggregate([
    {$unwind:"$Cases"},
    {$set:{ date: { $add: [ "$date", 3600000*8 ]}}},
    {$group:{
        _id:{year:{$year: "$date"},month:{ $month: {date:"$date"} }},
    
        New_Cases:{$sum: "$Cases.new_cases"}
    }},
    {$project:{New_Cases:1,date:1}},
    {$sort:{"_id":1}}

    ])
// 122 Docs

//6. Conduct trend analysis, i.e., for each month, compute the total number of new cases in each continent
db.owidnested.aggregate([
    {$unwind:"$Cases"},
    {$set:{ date: { $add: [ "$date", 3600000*8 ]}}},
    {$group:{
        _id:{year:{$year: "$date"},month:{ $month: {date:"$date"}}, continent:"$continent"},

        New_Cases:{$sum: "$Cases.new_cases"}
    }},
    {$project:{New_Cases:1,continent:1}},
    {$sort:{"_id":1,continent:1}}
   
    ])
// 63 Docs

//7.  Generate a list of EU countries that have implemented mask related responses (i.e., response measure contains the word “mask”).
db.rg.aggregate([
    {$lookup:
        {  from:"owidnested",
        localField:"Country",
        foreignField:"location",
        as:"owidinrg"}},
    {$unwind: "$owidinrg"},
    {$match:{'owidinrg.continent':"Europe"}},
    {$match:{$or:[{Response_measure: {$regex : ".*mask.*"}},{Response_measure: {$regex : ".*Mask.*"}}]}},
    {$group:{
        _id:"$Country"}},
    {$sort:{_id:1}},
    {$project:{_id:1}}
    ])
// 26 Docs
 
//8.  Compute the period (i.e., start date and end date) in which most EU countries has implemented MasksMandatory as the response measure. For NA values, use 1-Auguest 2020.
db.rg.aggregate([
    {$set:{date_start:{$cond:[{$eq:["$date_start",null]},ISODate("2020-08-01"),"$date_start"]}}},
    {$group:{_id:{date_start:"$date_start"}}},
    {$group:{_id:null,maxstartdate:{$max:"$_id.date_start"}
        ,minstartdate:{$min:"$_id.date_start"}
        }},
    {$addFields: {days_diff: {$divide: [{ $subtract: ["$maxstartdate", "$minstartdate"] }, 1000 * 60 * 60 * 24]}}},
    {$project: {_id:0,dates: {
            $map: {
                input: {$range: [0, {$add:["$days_diff",1]}] }, 
                as: "addate",
                in: {$add: ["$minstartdate", {$multiply:["$$addate", 86400000]}]} 
                 }}}},
    {$unwind: "$dates"},
    {$out:"dates"}]);

db.rg.aggregate([
    {$lookup:
        {  from:"owidnested",
        localField:"Country",
        foreignField:"location",
        as:"owidinrg"}},
    {$unwind: "$owidinrg"},
    {$match:{'owidinrg.continent':"Europe"}},
    {$group:{
        _id:"$Country"}},
    {$sort:{_id:1}},
    {$out:"europemm"}
    ])
 
db.europemm.aggregate([
    {$lookup:
        { from:"rg",
        localField:"_id",
        foreignField:"Country",
        as:"rgineuropemm"}},
    {$unwind:"$rgineuropemm"},
    {$match:{"rgineuropemm.Response_measure" : "MasksMandatory"}},
    {$set:{date_end:{$cond:[{$eq:["$rgineuropemm.date_end",ISODate("1970-01-01T07:30:00.000+07:30")]},ISODate("2020-08-01T08:00:00+08:00"),"$rgineuropemm.date_end"]}}},
    {$project:{_id:0,Country:"$rgineuropemm.Country",Response_measure:"$rgineuropemm.Response_measure",date_start:'$rgineuropemm.date_start',
    date_end:'$date_end'}
    {$out:"europerg"}
    ])

db.dates.aggregate([
    {$project:{_id:0,dates:1}},
    {$lookup:{
       from:"europerg",
        let:{
          dates:"$dates"
        },
        pipeline:[
            {$match:
                    {$and:[{$expr:{$lte:["$$dates","$date_end"]}},
                            {$expr:{$gte:["$$dates","$date_start"]}}
                            ]}}
            ]
        as:"countriesinrange"}},
    {$set:{noofcountries: {$size:"$countriesinrange"}}},
    {$project:{dates : 1, nofcountries:"$noofcountries"}},
    {$group:{_id:"$nofcountries",
    dateStart : {$min:"$dates"},
    dateEnd : {$max:"$dates"}}},
    {$sort: {"_id" : -1}},
    {$limit : 1}
    ])

    
//9.  Based on the period above, conduct trend analysis for Europe and North America, i.e., for each day during the period, compute the total number of new cases.
db.owidnested.aggregate([
    {$unwind:"$Cases"},
    {$match: {"date": {$gte: ISODate("2020-07-27T00:00:00.000+08:00"), $lte: ISODate("2020-08-01T00:00:00.000+08:00")}}},
    {$sort: {date: 1}},
    {$match: {continent: {$in: ["North America", "Europe"]}}},
    {$group: {_id: {date: "$date", continent: "$continent"},totalCases: {$sum: "$Cases.new_cases"}}},
    {$sort: {_id: 1}},
  ]); 
//12 Doc

//10. Generate a list of unique locations (countries) that have successfully flattened the curve 
//(i.e., achieved more than 14 days of 0 new cases, after recording more than 50 cases)

db.owidnested.aggregate([
    {$unwind:"$Cases"},
    {$match:{"Cases.total_cases":{$gt:50}}},
    
    {$group:{
        _id:{location:"$location",total:"$Cases.total_cases"},
        datearray:{$push:"$date"}}},
    {$sort:{"_id.total":1}}    
    {$project:{location:"$_id.location",datearray:1,
        No_Of_Consecutive_Days:{$size:"$datearray"}}},
    {$match:{No_Of_Consecutive_Days:{$gt:14}}},
    {$unwind:"$datearray"},
    {$group:{_id:"$location","lastDate":{$max:"$datearray"}}},
    {$sort:{_id:1}}
    {$out:"array"},
])

//Display Qn 10 Answer
db.array.find()
//26 Docs


//11. Second wave detection – generate a list of unique locations (countries) that have 
//flattened the curve (as defined above) but suffered upticks in new cases (i.e., after >= 14 days, 
//registered more than 50 cases in a subsequent 7-day window)

//Using Out From Qn 11
db.array.aggregate([
    {$project:{ 
        windowDay7: {$add: ["$lastDate", 3600000*24*7]}, 
        windowDay1: {$add: ["$lastDate", 3600000*24*1]},
        location:1
    }},
    {$lookup:
        {from:"owidnested",
        let:{
          day1:"$windowDay1"  
          location:"$_id"
          day7:"$windowDay7"
        },
        pipeline:[
            {$match:
                {$and:[
                    {$expr:{$lte:["$$day1","$date"]}},
                    {$expr:{$gte:["$$day7","$date"]}},
                    {$expr:{$eq:["$$location","$location"]}}
            ]}},
            {$unwind:"$Cases"},
            {$group:{_id:"$location", sumNewCase:{$sum:"$Cases.new_cases"}}},
        ] 
        as:"day7Owid"
        }},
    {$match:{"day7Owid.sumNewCase":{$gt:50}}},
    {$unwind:"$day7Owid"}
    {$project:{_id:1, total_cases_7days:"$day7Owid.sumNewCase"}}
    ])

//12. Display the top 3 countries in terms of changes from baseline in each of the place categories 
//(i.e., grocery and pharmacy, parks, transit stations, retail and recreation, residential, and workplaces)

//grocery_and_pharmacy_percent_change_from_baseline
db.gmrnested.aggregate([
    {$project:{
        "location":1, 
        "grocery_and_pharmacy_percent_change_from_baseline":"$baselines.grocery_and_pharmacy_percent_change_from_baseline", 
        }},
    {$unwind:"$grocery_and_pharmacy_percent_change_from_baseline"}
    {$project:{
        "location":1, 
        "grocery_and_pharmacy":{$cond : [{ $ne : ["$grocery_and_pharmacy_percent_change_from_baseline", NaN] }, "$grocery_and_pharmacy_percent_change_from_baseline", 0]},
    }},
    {$group:{
        _id:"$location", 
        "abschange":{$max:{$abs:"$grocery_and_pharmacy"}}, 
        "minimum":{$min:"$grocery_and_pharmacy"}, 
        "maximum":{$max:"$grocery_and_pharmacy"}}},
    {$sort:{abschange:-1, _id:1}},
    
    {$limit:3},
    {$project:{
        "location":1, 
        "grocery_and_pharmacy_change": {$cond:{if:{$eq:["$abschange", {$abs:"$minimum"}]}, then:"$minimum", else:"$maximum"}},
    }},
])

//parks_percent_change_from_baseline
db.gmrnested.aggregate([
    {$project:{
        "location":1, 
        "parks_percent_change_from_baseline":"$baselines.parks_percent_change_from_baseline", 
        }},
    {$unwind:"$parks_percent_change_from_baseline"}
    {$project:{
        "location":1, 
        "parks":{$cond : [{ $ne : ["$parks_percent_change_from_baseline", NaN] }, "$parks_percent_change_from_baseline", 0]},
    }},
    {$group:{
        _id:"$location", 
        "abschange":{$max:{$abs:"$parks"}}, 
        "minimum":{$min:"$parks"}, 
        "maximum":{$max:"$parks"}}},
    {$sort:{abschange:-1, _id:1}},
    
    {$limit:3},
    {$project:{
        "location":1, 
        "parks_change": {$cond:{if:{$eq:["$abschange", {$abs:"$minimum"}]}, then:"$minimum", else:"$maximum"}},
    }},
])

//transit_stations_percent_change_from_baseline
db.gmrnested.aggregate([
    {$project:{
        "location":1, 
        "transit_stations_percent_change_from_baseline":"$baselines.transit_stations_percent_change_from_baseline", 
        }},
    {$unwind:"$transit_stations_percent_change_from_baseline"}
    {$project:{
        "location":1, 
        "transit_stations":{$cond : [{ $ne : ["$transit_stations_percent_change_from_baseline", NaN] }, "$transit_stations_percent_change_from_baseline", 0]},
    }},
    {$group:{
        _id:"$location", 
        "abschange":{$max:{$abs:"$transit_stations"}}, 
        "minimum":{$min:"$transit_stations"}, 
        "maximum":{$max:"$transit_stations"}}},
    {$sort:{abschange:-1, _id:1}},
    
    {$limit:3},
    {$project:{
        "location":1, 
        "transit_stations_change": {$cond:{if:{$eq:["$abschange", {$abs:"$minimum"}]}, then:"$minimum", else:"$maximum"}},
    }},
])

//retail_and_recreation
db.gmrnested.aggregate([
    {$project:{
        "location":1, 
        "retail_and_recreation_percent_change_from_baseline":"$baselines.retail_and_recreation_percent_change_from_baseline", 
        }},
    {$unwind:"$retail_and_recreation_percent_change_from_baseline"}
    {$project:{
        "location":1, 
        "retail_and_recreation":{$cond : [{ $ne : ["$retail_and_recreation_percent_change_from_baseline", NaN] }, "$retail_and_recreation_percent_change_from_baseline", 0]},
    }},
    {$group:{
        _id:"$location", 
        "abschange":{$max:{$abs:"$retail_and_recreation"}}, 
        "minimum":{$min:"$retail_and_recreation"}, 
        "maximum":{$max:"$retail_and_recreation"}}},
    {$sort:{abschange:-1, _id:1}},
    
    {$limit:3},
    {$project:{
        "location":1, 
        "change": {$cond:{if:{$eq:["$abschange", {$abs:"$minimum"}]}, then:"$minimum", else:"$maximum"}},
    }},
])

//residential_percent_change_from_baseline
db.gmrnested.aggregate([
    {$project:{
        "location":1, 
        "residential_percent_change_from_baseline":"$baselines.residential_percent_change_from_baseline", 
        }},
    {$unwind:"$residential_percent_change_from_baseline"}
    {$project:{
        "location":1, 
        "residential":{$cond : [{ $ne : ["$residential_percent_change_from_baseline", NaN] }, "$residential_percent_change_from_baseline", 0]},
    }},
    {$group:{
        _id:"$location", 
        "abschange":{$max:{$abs:"$residential"}}, 
        "minimum":{$min:"$residential"}, 
        "maximum":{$max:"$residential"}}},
    {$sort:{abschange:-1, _id:1}},
    
    {$limit:3},
    {$project:{
        "location":1, 
        "residential_change": {$cond:{if:{$eq:["$abschange", {$abs:"$minimum"}]}, then:"$minimum", else:"$maximum"}},
    }},
])

//workplaces_percent_change_from_baseline
db.gmrnested.aggregate([
    {$project:{
        "location":1, 
        "workplaces_percent_change_from_baseline":"$baselines.workplaces_percent_change_from_baseline", 
        }},
    {$unwind:"$workplaces_percent_change_from_baseline"}
    {$project:{
        "location":1, 
        "workplaces":{$cond : [{ $ne : ["$workplaces_percent_change_from_baseline", NaN] }, "$workplaces_percent_change_from_baseline", 0]},
    }},
    {$group:{
        _id:"$location", 
        "abschange":{$max:{$abs:"$workplaces"}}, 
        "minimum":{$min:"$workplaces"}, 
        "maximum":{$max:"$workplaces"}}},
    {$sort:{abschange:-1, _id:1}},
    
    {$limit:3},
    
    {$project:{
        "location":1, 
        "workplaces_change": {$cond:{if:{$eq:["$abschange", {$abs:"$minimum"}]}, then:"$minimum", else:"$maximum"}},
    }},
])


//13. Conduct mobility trend analysis, i.e., in Indonesia, identify the date where more than 20,000 cases were recorded (D-day). 
//Based on D-day, show the daily changes in mobility trends for the 3 place categories (i.e., retail and recreation, workplaces, and grocery and pharmacy).

db.owidnested.aggregate([
    {$unwind:"$Cases"}
    {$project:{"location":1, "Cases.total_cases":1, "date":1}}
    {$match:{"location":"Indonesia"}},
    {$match:{"Cases.total_cases":{$gt:20000}}},
    {$sort:{"date":-1}}
    {$out:"indo_20000"}
])

db.gmrnested.aggregate([
    {$match:{"location":"Indonesia"}},
    {$project:{"date": {$subtract: ["$date", 3600000*8]}, "baselines":1}},
    {$out:"indo_bl"}
])

db.indo_20000.aggregate([
    {$project:{"location":1, "total_cases":"$Cases.total_cases", "date":1}},
    {$lookup:{
        from: "indo_bl",
        let:{
            gt20000_date:"$date"
        },
        pipeline: [
            {$match: {$expr:{$eq: ["$date","$$gt20000_date"]}}},
            {$project:{_id:0, "baselines":1}}
        ],
        as: "baseline"}},
    {$unwind: "$baseline"},
    {$sort:{"date":1}},
    {$project:{"location":1, "total_cases":1, "baselines":"$baseline.baselines", "date":1}}
    {$limit:28}
])
