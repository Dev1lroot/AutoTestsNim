import std/httpclient, std/json, system, os, base64

var data = readFile("autotests.json")
try:
  var i    = 0;
  var json = parseJSON(data)
  for test in json:
    try:
      if test["status"].getBool():
        # Пробуем выполнить автотест из списка
        echo "Launching: " & test["title"].getStr()
        echo "-----------------------------------------------------------------------"
  
        # Создаем HTTP-клиент и передаем в него запрос
        var  client = newHttpClient()
        var  data   = newMultipartData()
  
        # Подключение через NGINX AUTH
        try:
          client.headers["Authorization"] = "Basic " & base64.encode(test["request"]["auth"]["username"].getStr() & ":" & test["request"]["auth"]["password"].getStr())
        except:
          echo "- no auth provided"
  
        # Установка заголовков запроса
        try:
          for key in keys(test["request"]["headers"]):
            client.headers[key] = test["request"]["headers"][key].getStr()
            echo "- header: " & key & " \t\t" & test["request"]["headers"][key].getStr()
        except:
          echo "- no auth provided"
  
        if test["request"]["type"].getStr() == "POST":
          # Обрабатываем данные если запрос содержит POST-данные
          try:
            for key in keys(test["request"]["body"]):
              data[key] = test["request"]["body"][key].getStr()
              echo "- form data: " & key & " \t\t" & test["request"]["body"][key].getStr()
          except:
            echo "- can't extract multipart form data"
          # Выполняем запрос
          try:
            echo "-----------------------------------------------------------------------"
            echo client.postContent(test["request"]["link"].getStr(), multipart=data)
          except:
            echo "- can't execute POST request"
  
        if test["request"]["type"].getStr() == "GET":
          # Выполняем запрос
          try:
            echo "-----------------------------------------------------------------------"
            echo client.getContent(test["request"]["link"].getStr())
          except:
            echo "- can't execute GET request"
        echo "======================================================================="
      else:
        echo "Skipping: " & test["title"].getStr()
        echo "======================================================================="

    except:
      echo "Test #" & $i & " is broken"

    i = i + 1
except:
  echo "autotests.json failure"