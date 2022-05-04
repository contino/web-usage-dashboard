# fields = ['ip', 'ui', 'usr', '@timestamp', 'method', 'rline', 'ver', 'status', 'size', 'referrer', 'user_agent']
# example = {"ip": "197.200.145.108", "ui": "-", "usr": "-", "@timestamp": "05/Apr/2022:11:38:57 +0200", "method": "GET", "rline": "/icons/text.gif", "ver": "HTTP/1.1", "status": "404", "size": "220", "referrer": "\"http://www.almhuette-raith.at/apache-log/\"", "user_agent": "Mozilla/5.0 (Windows NT 6.1; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/100.0.4896.60 Safari/537.36"}

web_logs ={
  "mappings": {
    "properties": {
      "ip": {
        "type": "ip"
      },
      "ui": {
        "type": "text"
      },
      "usr": {
        "type": "text"
      },
      "@timestamp": {
        "type": "date",
        "format": "dd/MMM/yyyy:HH:mm:ss Z"
      },
      "method": {
        "type": "text",
          "fields" : {
            "keyword" : {
              "type" : "keyword",
              "ignore_above" : 256
            }
          }
      },
      "rline": {
        "type": "text",
          "fields" : {
            "keyword" : {
              "type" : "keyword",
              "ignore_above" : 256
            }
          }
      },
      "status": {
        "type": "text",
        "fields": {
          "keyword": {
            "type": "keyword",
            "ignore_above": 256
          }
        }
      },
      "size": {
        "type": "long"
      },
      "referrer": {
        "type": "text",
        "fields": {
          "keyword": {
            "type": "keyword",
            "ignore_above": 256
          }
        }
      },
      "user_agent": {
        "type": "text"
      }
    }
  }
}
