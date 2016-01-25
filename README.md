# Usage
```
QUERY='
{ "size": 10000,
  "query": {
    "range": {
      "time": {
        "gte": "now-300d/d",
        "lte": "now/d",
        "time_zone": "+09:00"
      }
    }
  }
}
'

curl -s -XGET 'http://localhost:9200/happy_rate/rate/_search' -d ''"$QUERY"'' | jq -r '.hits.hits[] | ._source | [.time,.rate] | @csv' | ruby week-hour-cal.rb
```
