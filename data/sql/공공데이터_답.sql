/*
mongoimport --db my_db --collection area --file area.json
mongoimport --db my_db --collection by_month --file by_month.json
mongoimport --db my_db --collection by_road_type --file by_road_type.json
mongoimport --db my_db --collection by_type --file by_type.json
*/
db.area.count()
db.area.find()

db.by_month.count()
db.by_month.find({},{month_data:1, _id:0})

db.by_road_type.count()
db.by_road_type.find()

db.by_type.count()
db.by_type.find()
db.by_type.aggregate([
    {$group:{_id:"$type"}}
])

//1. by_road_type : 강릉시(county 값) 교차로 내에서 일어난 총 사고 숫자를 출력한다.
db.by_road_type.find({county:"강릉시"})
db.by_road_type.find({county:"강릉시"},{"교차로내.accident_count":1})
db.by_road_type.find({county:"강릉시"},{"교차로내.accident_count":1, _id:0, city_or_province:1, county:1})
//2. by_road_type : 전국의 도로 종류 중에 “기타단일로” 에서 사망자수가 0 인 지역을 출력한다.
db.by_road_type.find({"기타단일로.death_toll":0},{_id:0, city_or_province:1, county:1, 기타단일로:1})
//3. by_type : 전국의 “차대차” 사고에서 100 회 이상 사고가 발생하였지만, 사망자 수가 0 회인 지역을 출력한다.
db.by_type.find(
    {type:"차대차", accident_count:{$gte:100}, death_toll:0},
    {_id:0, city_or_province:1, county:1}
)
//4. by_type : 전국의 “차대사람” 사고에서 사망자수가 0 회 이거나 중상자수가 0 회인 지역을 출력한다.
db.by_type.find(
    {type:"차대사람", $or:[{death_toll:0},{heavy_injury:0}]},
    {_id:0, city_or_province:1, county:1}
)
//5. area : 행정구역명이 시 라는 이름으로 끝나는 지역의 수를 출력한다.
db.area.find({county:/시$/},{_id:0}).sort({county:1})
db.area.find({county:/시$/},{_id:0}).count()

//6. area : 행정구역명이 군 이면서 인구수가 10 만 이상인 곳을 출력한다.인구순서대로 ASC
db.area.find(
    {county:/군$/, population:{$gte:100000}},
    {_id:0}
).sort({population:-1})
//6.1 area : 행정구역명이 시 이면서 인구수가 10 만 이상인 곳을 출력한다. 인구순서대로 DESC
db.area.find(
    {county:/시$/, population:{$gte:100000}},
    {_id:0}
).sort({population:-1})

//7. area : 행정구역명이 구 이면서, 이름의 첫 글자 초성이 “ㅇ” 인 행정구역명을 출력한다.
db.area.find(
    {county:{ $regex:/구$/, $gte:"아", $lt:"자"}},
    {_id:0}
)
//8. by_month : 서울시에서 한달에 200 회 이상 교통사고가 발생한 지역의 행정구역명을 출력한다.
db.by_month.find()
db.by_month.find(
    {city_or_province:"서울", "month_data.accident_count":{$gte:200}},
    {_id:0, county:1,}
)

db.by_month.find(
    {city_or_province:"서울", "month_data.accident_count":{$gte:200}},
    {_id:0, county:1,"month_data.month":1}
)
//9. by_month : 1 월에 중상자 수가 0 명이고, 2 월에 사망자 수가 0 명인 광역단체명과 행정구역명을 출력한다.
db.by_month.find({},{_id:0,month_data:1})
//$elemMatch
db.by_month.find(
    {$and:[
        {month_data:{$elemMatch:{month:"01월",heavy_injury:0}}},
        {month_data:{$elemMatch:{month:"02월",death_toll:0}}}
        ]},
    {_id:0, city_or_province:1, county:1}
)
//10. by_road_type : 전국의 도로 종류 중 “기타단일로” 에서 사망자수가 0 인 광역단체명,행정구역명, 기타단일로의 사망자수를 출력한다.
db.by_road_type.find(
    {"기타단일로.death_toll":0},
    {_id:0, city_or_province:1, county:1, "기타단일로.death_toll":1}
)

//11. by_month : 서울시에서 한달에 200 회 이상 사고가 발생한 document 를 찾고, 200 회
//이상 사고가 발생한 월의 정보가 한달치만(month_data.$) 출력되어야 한다. month_data, 행정구역명을 출력한다.
db.by_month.find(
    {city_or_province:"서울", "month_data.accident_count":{$gte:200}},
    {"month_data.$":1, county:1 }
)
/*
mongoimport --db my_db --collection local --file local.json
mongoimport --db my_db --collection city_or_province --file city_or_province.json
*/

//1. area : 광역시도별 건수 - $group, $sort
db.area.find()
db.area.aggregate([
    {
        $group:{
            _id:"$city_or_province",
            count:{$sum:1}
        }
    },
    {
        $sort:{count:-1}
    }
])
//2. area: 광역시도별 인구수의 합계 ( 인구수 250 만 보다 크고, 많은 순서대로 정렬) - $group, $match, $sort
db.area.aggregate([
    {
        $group:{
            _id:"$city_or_province",
            pop_sum_cnt:{$sum:"$population"}
        }
    },
    {
        $match:{pop_sum_cnt:{$gt:250 * 10000}}
    },
    {
        $sort:{pop_sum_cnt:-1}
    }
])
//3. local : 인건비의 광역시도별 평균 지출 비용 ( 소수점이하 버림, 큰 순서대로 정렬)- $match, $group, $project, $sort
db.local.find()
db.local.aggregate([
    {$match:{main_category:"인건비"}},
    {$group: {
        _id:"$city_or_province",
        expense_avg:{$avg:"$this_term_expense"}
    }},
    {$project: {"인건비평균":{$trunc:["$expense_avg",0]}}},
    {$sort:{"인건비평균":-1}}
])
//4. city_or_province : 자치단체별로 총 사용한 운영비와,세부항목별로 총 사용한 운영비를 같이 출력한다. - $facet, $group 스테이지
db.city_or_province.aggregate([
    {
        $facet:{
            by_city_or_province:[
                {
                    $group:{
                        _id:"$city_or_province",
                        sum_expense: {$sum:"$this_term_expense"}
                    }
                }
            ],
            by_sub_category:[
                {
                    $group:{
                        _id:"$sub_category",
                        main_category:{$first:"$main_category"},
                        sum_expense:{$sum:"$this_term_expense"}
                    }
                }
            ]
        }
    }
])
//5. city_or_province : 자치단체를 랜덤하게 두곳을 골라서 올해 가장 많이 사용한 운영비 세부항목을 출력한다 - $group, $sort, $sample
db.city_or_province.aggregate([
    {$sort:{this_term_expense:-1}},
    {$group:{
        _id:"$city_or_province",
        main_catetory:{$first:"$main_category"},
        sub_category:{$first:"$sub_category"},
        this_term_expense:{$first:"$this_term_expense"}
    }},
    {$sample:{size:4}}
])

//$facet, $bucket, $bucketAuto
db.createCollection("movies")
db.movies.insertMany(
 [
  { _id : 1, title : "Terminator 2", year : 1991, price : 100, category : [ "SF", "ACTION" ] },
  { _id : 2, title : "Salt", year : 2010, price : 150, category : [ "ACTION", "CRIME" ] },
  { _id : 3, title : "Dirty Dancing", year : 1987, price : 70, category : [ "DRAMA", "MUSIC","ROMANCE" ] }
 ]
)
db.movies.find()

db.movies.aggregate([ {
    $facet : {
     "byCategory" : [
        { $unwind : "$category" },
        { $sortByCount : "$category" }
     ],
    "byPrice" : [
         {
             $bucket : {
                 groupBy : "$price",
                 boundaries : [ 0, 50, 100, 150, 200],
                 output : {
                 "count" : { $sum : 1 },
                 "titles" : { $push : "$title" }
                 }
            }
        }
    ],
    "byYear(Auto)": [
        {
             $bucketAuto : {
                groupBy : "$year",
                buckets : 4
            }
        }
    ]
   }
 }] )