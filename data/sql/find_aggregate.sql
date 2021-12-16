//db 목록 확인
show dbs;
//mymongo_db 를 사용하겠다. 없으면 새로 생성
use mymongo_db;

//db 상태확인
db.stats()

//people collection 생성 capped true로 설정
db.createCollection("people", {capped:true, size:10000})

//people collection 생성 capped false로 설정
db.createCollection("people");

//people collection 제거
db.people.drop();

//컬렉션 목록 확인
show collections;
//peolple collection이 capped 인지를 확인
db.people.isCapped();

for(i=0; i<1000; i++){
    db.people.insertOne({x:i});
};

//collection 상태확인
db.people.stats();

//select * from people
db.people.find();

db.createCollection("emp");
//admin db로 switching
use admin;
//emp -> employees
db.runCommand({ "renameCollection": "mymongo_db.emp", "to": "mymongo_db.employees","dropTarget": true });

//mymongo_db로 switching
use mymongo_db;
show collections;

db.people.getIndexes();
//x 필드를 index로 DESC(-1) 설정
db.people.createIndex({x:-1})

db.people.drop();
show collections;
db.createCollection("people");

db.people.insertOne(
     { user_id: "bcd001", age:45,status:"A" }
);
db.people.find();

db.people.insertMany([
    { user_id: "bcd002", age:25,status:"B" },
    { user_id: "bcd003", age:50,status:"A" },
    { user_id: "bcd004", age:35,status:"A" },
    { user_id: "abc001", age:28,status:"B" }
]);
//- SELECT * FROM people
db.people.find();
//- SELECT _id, user_id, status FROM people
db.people.find({ }, { user_id: 1, status: 1 });
//- SELECT user_id, status FROM people
db.people.find({ },{ user_id: 1, status: 1, _id: 0 });

//- SELECT * FROM people WHERE status = 'A'
db.people.find({ status: "A" });
//- SELECT user_id,status from people where status = 'A'
db.people.find({ status: "A" },{ user_id:1, status:1,_id:0});
//- SELECT * from people where status != 'A'
db.people.find({ status: { $ne:"A" }});
// - select user_id,status,age from people where user_id != 'abc001'
db.people.find({user_id:{$ne:'abc001'}},{user_id:1,status:1,age:1,_id:0});

//- SELECT * FROM people WHERE status = 'A' AND age = 50
db.people.find({ status: "A", age: 50 });
//- SELECT * FROM people WHERE status = "A" OR age = 50
db.people.find({ $or: [ { status: "A" } , { age: 25 } ] });
// status != A or age = 35
db.people.find({ $or: [ {status: {$ne:'A'}},{age:35} ]});

//- SELECT * FROM people WHERE age > 25
db.people.find({ age: { $gt: 25 } });
//- SELECT * FROM people WHERE age < 25
db.people.find({ age: { $lt: 25 } });
//- SELECT * FROM people WHERE age > 25 AND age <= 50
db.people.find({ age: { $gt: 25, $lte: 50 } });
//- SELECT * FROM people WHERE age in (5,15)
db.people.find( { age: { $in: [ 25, 15 ] } } );
//- SELECT * FROM people WHERE age not in (5,15)
db.people.find( { age: { $nin: [ 5, 25 ] } } );

//- SELECT * FROM people WHERE user_id like "%cd%"
db.people.find( { user_id: { $regex: /cd/ } } );
db.people.find({ user_id : /^ab/});

//- SELECT * FROM people WHERE user_id like "bc%"  ^ : 시작하는
db.people.find( { user_id: { $regex: /^bc/ } } );
//- SELECT * from people where user_id like "%01" $ : 끝나는
db.people.find({user_id:{$regex:/01$/}});

//- SELECT * FROM people WHERE status = "A" ORDER BY user_id ASC
db.people.find( { status: "A" } ).sort( { user_id: 1 } );
//- SELECT * FROM people WHERE status = "A" ORDER BY user_id DESC
db.people.find( { status: "A" } ).sort( { user_id: -1 } );

//age > 40 and user_id = %cd%
db.people.find({age:{$gt:40},user_id:{$regex:/cd/}},{user_id:1,age:1, _id:0}).sort({user_id:1});
db.people.find();

//status in ('A','C') and  25<= agg <=45
db.people.insertOne({user_id:"cde001",age:45, status:"C"});
db.people.find({status:{$in:['A','C']},age:{$gte:25,$lte:45}},{_id:0,user_id:1,status:1,age:1}).explain();

//- SELECT COUNT(*) FROM people
db.people.count();
//- select count(*) from people where age > 30
db.people.count({ age : { $gt:30 }});

db.people.insertOne({age:55, status:"D"});
//- SELECT COUNT(user_id) FROM people : user_id 컬럼의 값이 존재하는 row count
db.people.count( { user_id: { $exists: false } } );
//- SELECT DISTINCT(status) FROM people
db.people.aggregate( [{ $group : {_id: "$status" }}] );

db.people.findOne({age:{$gt:20}});

//- SELECT * FROM people LIMIT 1
db.people.find().limit(1);

db.people.find().limit(3).skip(1);

db.people.find();
//- UPDATE people SET status = "C" WHERE age > 45
db.people.updateMany( { age: { $gt: 45 } }, { $set: { status: "C" } } );

// 1개의 Document만 수정하려면 updateOne을 사용함
db.people.updateOne( { age: { $lte: 25 } }, { $set: { status: "D" } } );

//- UPDATE people SET age = age + 3 WHERE status = "A"
db.people.updateMany( { status: "A" } , { $inc: { age: 3 } } );

//- DELETE FROM people WHERE status = "D"
db.people.deleteMany( { status: "D" } );
// status = 'C' 한개의 document만 삭제
db.people.deleteOne({"status":"C"});

//- DELETE FROM people
db.people.deleteMany({})

db.people.updateOne(
   { user_id: "bcd001" },
   { $unset: { status: "", age: 0 } }
);

db.people.find();

//Provides information on the query plan for the db.collection.find() method.
db.people.find().explain();

//배열값을 포함하고 있는 document내의 field이름 변경하기
db.createCollection("character");
db.character.insertMany([
 {name: 'x', inventory:['pen','cloth','pen']},
 {name: 'y', inventory:['book','cloth'], position:{x:1, y:5}},
 {name: 'z', inventory:['wood','pen'], position:{x:0, y:9}}
]);
db.character.find();
//inventory 필드의 값 중에서 pen -> pencil
db.character.updateMany(
 {},
 {$set:{"inventory.$[penValue]":"pencil"}},
 {arrayFilters:[{penValue:'pen'}]
});

//name = z , pencil -> pencils
db.character.updateMany(
 {name:'z'},
 {$set:{"inventory.$[penValue]":"pencils"}},
 {arrayFilters:[{penValue:'pencil'}]
});

db.character.updateMany(
 {inventory:"cloth"},
 {$set:{"inventory.$":"clothes"}
});

db.character.updateMany(
    {inventory:"clothes"},
    {$set:{"inventory.$":"cloth"}}
);
db.character.find();

db.character.insertMany([
{name: 'x', inventory:['pen1','cloth1','pen1','cloth1']},
{name: 'y', inventory:['pen1','cloth1','pen1','cloth1','computer']}
]);

//pen1 -> pencil2
db.character.updateMany(
 {},
 {$set:{"inventory.$[penValue]":"pencil2"}},
 {arrayFilters:[{penValue:'pen1'}]
});
//cloth1 -> cloth2 배열의 값들 중에서 일부만 변경한다.
db.character.updateMany(
 {inventory:"cloth1"},
 {$set:{"inventory.$":"cloth2"}
});

//$push 연산자를 사용해서 배열에 값 추가하기
db.createCollection("developer");
db.developer.insertMany([
 {name:"Rohit", language:["C#","Python","Java"],
personal:{age:25,semesterMarks:[70,73.3,76.5,78.6]}},
 {name:"Sumit", language:["Java","Perl","C#"],
personal:{age:24,semesterMarks:[89,80.1,78,71]}}
]);

db.developer.find({},{_id:0});

db.developer.updateOne({name: "Rohit"}, {$push: {language: "C++"}});
db.developer.updateOne({name: "Sumit"}, {$push: {language: {$each: ["C", "Ruby", "Go"]}}});
db.developer.updateOne({name: "Sumit"}, {$push: {"personal.semesterMarks": {$each: [89,76.4]}}});
db.developer.updateOne({name: "Rohit"}, {$push: { language: { $each: ["C", "Go"], $sort: 1}}});  //, $slice: 4
db.developer.updateOne({name: "Sumit"}, {$push: { language: { $each: ["Cobol", "Fortran"], $sort: -1, $slice:4}}});

db.employees.insert([
  {"number":1001,"last_name":"Smith","first_name":"John","salary":62000,"department":"sales", hire_date:ISODate("2016-01-02")},
  {"number":1002,"last_name":"Anderson","first_name":"Jane","salary":57500,"department":"marketing", hire_date:ISODate("2013-11-09")},
  {"number":1003,"last_name":"Everest","first_name":"Brad","salary":71000,"department":"sales", hire_date:ISODate("2017-02-03")},
  {"number":1004,"last_name":"Horvath","first_name":"Jack","salary":42000,"department":"marketing", hire_date:ISODate("2017-06-01")},
]);
db.employees.find();
// select * from employees where hire_date > "2017-01-01"
db.employees.find({hire_date:{$gte:ISODate("2017-01-01")}});

/*
mongoimport --db mymongo_db --collection area --file area.json
mongoimport --db mymongo_db --collection by_month --file by_month.json
mongoimport --db mymongo_db --collection by_road_type --file by_road_type.json
mongoimport --db mymongo_db --collection by_type --file by_type.json
*/

//car accident (교통사고) 데이터
db.area.count();
db.area.find();

db.by_month.count();
db.by_month.find();
db.by_month.find({},{month_data:1, _id:0});

db.by_road_type.count();
db.by_road_type.find();

db.by_type.count();
db.by_type.find();
db.by_type.aggregate([
    {$group:{_id:"$type"}}
]);

//1. by_road_type : 강릉시(county 값) 교차로 내에서 일어난 총 사고 숫자를 출력한다.
db.by_road_type.find({county:"강릉시"},{"county":1,"city_or_province":1,"교차로내.accident_count":1,_id:0});

//2. by_road_type : 전국의 도로 종류 중에 “기타단일로” 에서 사망자수가 0 인 지역을 출력한다.
db.by_road_type.find();
db.by_road_type.find({"기타단일로.death_toll":0});
db.by_road_type.find({"기타단일로.death_toll":0},{"city_or_province":1,"county":1,"기타단일로":1,_id:0});
//3. by_type : 전국의 “차대차” 사고에서 100 회 이상 사고가 발생하였지만, 사망자 수가 0 회인 지역을 출력한다.
db.by_type.find();
db.by_type.find(
    {type:"차대차",accident_count:{$gte:100},death_toll:0},
    {"city_or_province":1,"county":1,"accident_count":1,_id:0}
).sort({accident_count:-1});

//4. by_type : 전국의 “차대사람” 사고에서 사망자수가 0 회 이거나 중상자수가 0 회인 지역을 출력한다.
db.by_type.find(
    {type:"차대사람", $or:[{death_toll:0},{heavy_injury:0}]},
    {"city_or_province":1,"county":1,"accident_count":1,death_toll:1,heavy_injury:1,_id:0}).sort({accident_count:-1});

//5. area : 행정구역명이 시 라는 이름으로 끝나는 지역의 수를 출력한다.
db.area.find({county:/시$/},{_id:0}).sort({population:-1});
db.area.find({county:/시$/},{_id:0}).count();
//6. area : 행정구역명이 군 이면서 인구수가 10 만 이상인 곳을 출력한다.인구순서대로 ASC
db.area.find({county:/군$/, population:{$gte:100000} },{_id:0}).sort({population:1});
//6.1 area : 행정구역명이 시 이면서 인구수가 10 만 이상인 곳을 출력한다. 인구순서대로 DESC
db.area.find({county:/군$/, population:{$gte:100000} },{_id:0}).sort({population:-1});

//7. area : 행정구역명이 구 이면서, 이름의 첫 글자 초성이 “ㅇ” 인 행정구역명을 출력한다.  $gte:아 , $lt:자
db.area.find(
    {county:{$regex:/구$/, $gte:"아", $lt:"자"}},
    {_id:0}
);

//8. by_month : 서울시에서 한달에 200 회 이상 교통사고가 발생한 지역의 행정구역명을 출력한다.
db.by_month.find(
    {city_or_province:"서울","month_data.accident_count":{$gte:200}},
    {_id:0,county:1,"month_data":1}
    );

//9. by_month : 1 월에 중상자 수가 0 명이고, 2 월에 사망자 수가 0 명인 광역단체명과 행정구역명을 출력한다.
db.by_month.find();
db.by_month.find(
    {$and:[
        {month_data:{$elemMatch:{"month":"01월","heavy_injury":0}}},
        {month_data:{$elemMatch:{"month":"02월","death_toll":0}}}
    ]},
    {_id:0,"city_or_province":1,"county":1, month_data:1}
);

db.by_month.find(
    {$and:[
        {month_data:{$elemMatch:{"month":"01월","heavy_injury":0}}},
        {month_data:{$elemMatch:{"month":"02월","death_toll":0}}}
    ]},
    {_id:0,"city_or_province":1,"county":1, month_data:{$elemMatch:{"month":"01월"}}}
);


//10. by_road_type : 전국의 도로 종류 중 “기타단일로” 에서 사망자수가 0 인 광역단체명,행정구역명, 기타단일로의 사망자수를 출력한다.
db.by_road_type.find({"기타단일로.death_toll":0},{_id:0,"city_or_province":1,"county":1,"기타단일로.death_toll":1});

//11. by_month : 서울시에서 한달에 200 회 이상 사고가 발생한 document 를 찾고, 200 회
//이상 사고가 발생한 월의 정보가 한달치만(month_data.$) 출력되어야 한다. month_data, 행정구역명을 출력한다.
db.by_month.find(
    {"city_or_province":"서울","month_data.accident_count":{$gte:200}},
    {"month_data.$":1,county:1,_id:0});


//데이터 집계를 위한 Aggregate 함수
db.createCollection("orders");

show collections;

db.orders.insertMany([
{
 cust_id: "abc123",
 ord_date: ISODate("2012-01-02T17:04:11.102Z"),
 status: 'A',
 price: 100,
 items: [ { sku: "xxx", qty: 25, price: 1 },
 { sku: "yyy", qty: 25, price: 1 } ]
 },
 {
 cust_id: "abc123",
 ord_date: ISODate("2012-01-02T17:04:11.102Z"),
 status: 'A',
 price: 500,
 items: [ { sku: "xxx", qty: 25, price: 1 },
 { sku: "yyy", qty: 25, price: 1 } ]
 },
 {
 cust_id: "abc123",
 ord_date: ISODate("2012-01-02T17:04:11.102Z"),
 status: 'B',
 price: 130,
 items: [ { sku: "jkl", qty: 35, price: 2 },
 { sku: "abv", qty: 35, price: 1 } ]
 },
 {
 cust_id: "abc123",
 ord_date: ISODate("2012-01-02T17:04:11.102Z"),
 status: 'B',
 price: 230,
 items: [ { sku: "jkl", qty: 25, price: 2 },
 { sku: "abv", qty: 25, price: 1 } ]
 },
 {
 cust_id: "abc123",
 ord_date: ISODate("2012-01-02T17:04:11.102Z"),
 status: 'A',
 price: 130,
 items: [ { sku: "xxx", qty: 15, price: 1 },
 { sku: "yyy", qty: 15, price: 1 } ]
 },
 {
 cust_id: "abc456",
 ord_date: ISODate("2012-02-02T17:04:11.102Z"),
 status: 'C',
 price: 70,
 items: [ { sku: "jkl", qty: 45, price: 2 },
 { sku: "abv", qty: 45, price: 3 } ]
 },
 {
 cust_id: "abc456",
 ord_date: ISODate("2012-02-02T17:04:11.102Z"),
 status: 'A',
 price: 150,
 items: [ { sku: "xxx", qty: 35, price: 4 },
 { sku: "yyy", qty: 35, price: 5 } ]
 },
 {
 cust_id: "abc456",
 ord_date: ISODate("2012-02-02T17:04:11.102Z"),
 status: 'B',
 price: 20,
 items: [ { sku: "jkl", qty: 45, price: 2 },
 { sku: "abv", qty: 45, price: 1 } ]
 },
 {
 cust_id: "abc456",
 ord_date: ISODate("2012-02-02T17:04:11.102Z"),
 status: 'B',
 price: 120,
 items: [ { sku: "jkl", qty: 45, price: 2 },
 { sku: "abv", qty: 45, price: 1 } ]
 },
 {
 cust_id: "abc780",
 ord_date: ISODate("2012-02-02T17:04:11.102Z"),
 status: 'B',
 price: 260,
 items: [ { sku: "jkl", qty: 50, price: 2 },
 { sku: "abv", qty: 35, price: 1 } ]
 }
]);

db.orders.find();
//1. select count(*) as count from orders
db.orders.aggregate([
    {
        $group:{_id:null, order_count:{$sum:1}}
    }
]);
//2.select sum(price) as total from orders
db.orders.aggregate([
    {
        $group:{_id:null, price_total:{$sum:"$price"}}
    }
]);
db.orders.aggregate([
    {
        $group:{_id:null, price_total:{$avg:"$price"}}
    }
]);
db.orders.aggregate([
    {
        $group:{_id:null, price_total:{$max:"$price"}}
    }
]);

//3.select cust_id,sum(price) as total from orders group by cust_id
db.orders.aggregate([
    {
        $group:{_id:"$cust_id", price_total:{$sum:"$price"}}
    }
]);
//4.select cust_id,sum(price) as total from orders group by cust_id order by total asc
db.orders.aggregate([
    {
        $group:{_id:"$cust_id", price_total:{$sum:"$price"}}
    },
    {
        $match:{price_total:{$gt:500}}
    },
    {
        $project:{
            _id:0,
            cust_id:"$_id",
            price_total:1
        }
    },
    {
        $sort:{price_total:1}
    }
]);

db.orders.insertOne({
 cust_id: "abc456",
 ord_date: ISODate("2012-04-11T16:04:11.102Z"),
 status: 'C',
 price: 1000,
 items: [ { sku: "jkl", qty: 45, price: 2 },
 { sku: "abv", qty: 45, price: 3 } ]
 });
 db.orders.find();

//5.select cust_id,ord_date,sum(price) as total from orders group by cust_id,ord_date
db.orders.aggregate([
    {
        $group:{
            _id:{
                cust_id:"$cust_id",
                order_date: {$dateToString:{
                    format:"%Y-%m-%d",
                    date:"$ord_date"
                }}
            },
            total:{$sum:"$price"}
        }
    },
    {
        $project:{_id:0,cust_id:"$_id.cust_id",order_date:"$_id.order_date",total:1}
    },
    {
        $sort:{"_id.cust_id":1, "_id.order_date":1}
    }
]);
//6.select cust_id,count(*) from orders group by cust_id having count(*) > 1
db.orders.aggregate([
    {$group:{_id:"$cust_id",count:{$sum:1}}},
    {$match:{count:{$gt:1}}}
]);
//7.select status,count(*) from orders group by status having count(*) > 1
db.orders.aggregate([
    {$group:{_id:"$status",count:{$sum:1}}},
    {$match:{count:{$gt:1}}}
]);
//8.select status,sum(price) as total from orders group by status
db.orders.aggregate([
    {$group:{_id:"$status",total:{$sum:"$price"}}}
]);

//9.select cust_id,ord_date,sum(price) as total from orders group by cust_id,ord_date having total > 350
db.orders.aggregate([
    {
        $group:{
            _id:{
                cust_id:"$cust_id",
                order_date: {$dateToString:{
                    format:"%Y-%m-%d",
                    date:"$ord_date"
                }}
            },
            total:{$sum:"$price"}
        }
    },
    {
        $project:{_id:0,cust_id:"$_id.cust_id",order_date:"$_id.order_date",total:1}
    },
    {   $match:{total:{$gt:350}}},
    {
        $sort:{"_id.cust_id":1, "_id.order_date":1}
    }
]);
//10.select cust_id,sum(price) as total from orders where status = 'A' group by cust_id
db.orders.aggregate([
    {   $match:{status:"A"}},
    {
        $group:{_id:"$cust_id", price_total:{$sum:"$price"}}
    },
    {
        $project:{
            _id:0,
            cust_id:"$_id",
            price_total:1
        }
    },
    {
        $sort:{price_total:1}
    }
]);
//11.select cust_id,ord_date,sum(price) as total from orders where stauts ='A' group by cust_id,ord_date having total > 140
db.orders.aggregate([
    {   $match:{status:"A"}},
    {
        $group:{
            _id:{
                cust_id:"$cust_id",
                order_date: {$dateToString:{
                    format:"%Y-%m-%d",
                    date:"$ord_date"
                }}
            },
            total:{$sum:"$price"}
        }
    },
    {
        $project:{_id:0,cust_id:"$_id.cust_id",order_date:"$_id.order_date",total:1}
    },
    {   $match:{total:{$gt:140}}},
    {
        $sort:{"_id.cust_id":1, "_id.order_date":1}
    }
]);

//12.select cust_id, sum(li.qty) as qty from orders o, order_lineitem li where o_id = li.order_id group by cust_id
db.orders.find();
db.orders.count();
db.orders.aggregate([
    {$unwind:"$items"},
    {$group:{_id:"$cust_id",qty_sum:{$sum:"$items.qty"}}},
    {$sort:{qty_sum:-1}}
]);

/*
13. select count(*)
from (
    select cust_id,ord_date
      from orders
    group by cust_id,ord_date
    ) as d
*/
db.orders.aggregate([
    {
        $group:{
            _id:{
                cust_id:"$cust_id",
                order_date: {$dateToString:{
                    format:"%Y-%m-%d",
                    date:"$ord_date"
                }}
            },
            total:{$sum:"$price"}
        }
    },
    {$group:{_id:null,count:{$sum:1}}},
    {$project:{_id:0}}
]);

//$unwind 연산자 사용하기  Document 내의 배열 필드를 기반으로 각각의 Document 로 분리
//items collection  생성
db.createCollection("items");
db.items.insertMany([
{ "_id" : 1, "item" : "abc", "price" : 10, "quantity" : 2, "date" : ISODate("2014-01-01T08:00:00Z"),"sizes": [ "S", "M"] },
{ "_id" : 2, "item" : "jkl", "price" : 20, "quantity" : 1, "date" : ISODate("2014-02-03T09:00:00Z"),"sizes": [ "S"] },
{ "_id" : 3, "item" : "xyz", "price" : 5, "quantity" : 5, "date" : ISODate("2014-02-03T09:05:00Z"),"sizes": [ "S", "M","L"] },
{ "_id" : 4, "item" : "abc", "price" : 10, "quantity" : 10, "date" : ISODate("2014-02-15T08:00:00Z"),"sizes": [ "S", "M","L"] },
{ "_id" : 5, "item" : "xyz", "price" : 5, "quantity" : 10, "date" : ISODate("2014-02-15T09:05:00Z"),"sizes": [ "S", "M","L","XL"] },
{ "_id" : 6, "item" : "xyz", "price" : 5, "quantity" : 5, "date" : ISODate("2014-02-15T12:05:10Z"),"sizes": [ "S", "M","L"] },
{ "_id" : 7, "item" : "xyz", "price" : 5, "quantity" : 10, "date" : ISODate("2014-02-15T14:12:12Z"),"sizes": [ "S", "M","L","XL"] }
]);
db.items.find();
//$unwind
db.items.aggregate([
    {$unwind:"$sizes"}
]);
//$avg
db.items.aggregate([
 {
     $group:{
         _id: { year:{$year:"$date"},
                month:{$month:"$date"},
                day:{$dayOfMonth:"$date"}
              },
         totalPrice: {$sum:{$multiply:["$price","$quantity"]}},
         avgQuantity: {$avg:"$quantity"},
         count: {$sum:1}
     }
 }
]);
//$first
db.items.aggregate(
 [
     {
         $group:
         {
            _id: "$item",
            firstSalesDate: { $first: "$date" }
         }
     },
     {
        $sort: { item: 1, date: 1 }
     }
 ]
);

//$last
db.items.aggregate(
 [
     {
         $group:
         {
            _id: "$item",
            firstSalesDate: { $last: "$date" }
         }
     },
     {
        $sort: { item: 1, date: 1 }
     }
 ]
);
//$min
db.items.aggregate(
 [
     {
         $group:
         {
            _id: "$item",
            min_quantity: { $min: "$quantity" }
         }
     },
     {
        $sort: { item: 1, quantity: 1 }
     }
 ]
);
//$unwind
db.items.aggregate([
     {
        $unwind:"$sizes"
     },
     {
        $group:
        {
            _id: "$sizes",
            countSizes: {$sum:1},
        }
     }
]);
