# POC для Docker health check
В этом примере запускается простой контейнер с ruby-кодом, который раз в 10 минут меняет свое состояние со здорового на нездоровое.

## Как запустить этот пример
в первом окне терминала надо собрать и запустить контейнер
```
~> docker build -t hc-test .
~> docker run -it hc-test:latest
```

во втором окне терминала запустить команду для проверки статуса контейнера
```
~> date && docker ps
Mon Dec  7 15:49:47 MSK 2020
CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS                    PORTS               NAMES
3d24d2189074        hc-test:latest      "/bin/sh -c 'ruby /a…"   15 minutes ago      Up 15 minutes (healthy)                       vigilant_wozniak
~>
~> date && docker ps
Mon Dec  7 15:51:44 MSK 2020
CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS                      PORTS               NAMES
3d24d2189074        hc-test:latest      "/bin/sh -c 'ruby /a…"   17 minutes ago      Up 17 minutes (unhealthy)                       vigilant_wozniak
```
см healthy и unhealthy в поле STATUS

## Как это работает
в Dockerfile есть опция HEALTHCHECK. Она указывает какую команду запускать внутри контейнера для проверки и как часто.

Если команда завершится с кодом-возврата 0 значит приложение живо-здорово. Если код другой - не здорово. Подобнее читать тут https://docs.docker.com/engine/reference/builder/#healthcheck

## Как это можно использовать
В однохостовом режиме докер просто пометит проблемные контейнеры как unhealthy и сгенерирует health_status событие. В облачном же режиме он ещё и отключит этот контейнер и заменит его на новый, всё ещё здоровый. Быстро и автоматически.

## Как посмотреть события health_status
вот так
```
~> docker events --filter event=health_status
2020-12-07T16:20:27.145670483+03:00 container health_status: healthy 3d24d21890740aa449cf9766606d53ce833206fdba75c94430f383750653dac3 (image=hc-test:latest, name=vigilant_wozniak)
2020-12-07T16:31:30.176815631+03:00 container health_status: unhealthy 3d24d21890740aa449cf9766606d53ce833206fdba75c94430f383750653dac3 (image=hc-test:latest, name=vigilant_wozniak)
2020-12-07T16:40:02.394316160+03:00 container health_status: healthy 3d24d21890740aa449cf9766606d53ce833206fdba75c94430f383750653dac3 (image=hc-test:latest, name=vigilant_wozniak)
2020-12-07T16:51:05.223649796+03:00 container health_status: unhealthy 3d24d21890740aa449cf9766606d53ce833206fdba75c94430f383750653dac3 (image=hc-test:latest, name=vigilant_wozniak)
```

## Как посмотреть логи проверок health
Надо посмотреть в соответствующий раздел вывода docker inspect
```
docker inspect vigilant_wozniak  --format '{{json .State.Health}}'
{"Status":"healthy","FailingStreak":0,"Log":[{"Start":"2020-12-07T13:24:58.214009984Z","End":"2020-12-07T13:24:58.381164646Z","ExitCode":0,"Output":"App is OK!\n"},{"Start":"2020-12-07T13:25:28.375728129Z","End":"2020-12-07T13:25:28.510338097Z","ExitCode":0,"Output":"App is OK!\n"},{"Start":"2020-12-07T13:25:58.509237089Z","End":"2020-12-07T13:25:58.650968218Z","ExitCode":0,"Output":"App is OK!\n"},{"Start":"2020-12-07T13:26:28.645551461Z","End":"2020-12-07T13:26:28.786463208Z","ExitCode":0,"Output":"App is OK!\n"},{"Start":"2020-12-07T13:26:58.77657715Z","End":"2020-12-07T13:26:58.933122425Z","ExitCode":0,"Output":"App is OK!\n"}]}
```

А есть установлен jq, то можно сделать вывод более читаемым
```
docker inspect vigilant_wozniak  --format '{{json .State.Health}}'| jq
{
  "Status": "healthy",
  "FailingStreak": 0,
  "Log": [
    {
      "Start": "2020-12-07T14:00:37.722079621Z",
      "End": "2020-12-07T14:00:37.860876975Z",
      "ExitCode": 0,
      "Output": "App is OK!\n"
    },
    {
      "Start": "2020-12-07T14:01:07.851083389Z",
      "End": "2020-12-07T14:01:07.991893126Z",
      "ExitCode": 0,
      "Output": "App is OK!\n"
    },
    {
      "Start": "2020-12-07T14:01:37.983161925Z",
      "End": "2020-12-07T14:01:38.126854949Z",
      "ExitCode": 0,
      "Output": "App is OK!\n"
    },
    {
      "Start": "2020-12-07T14:02:08.116458432Z",
      "End": "2020-12-07T14:02:08.286825393Z",
      "ExitCode": 0,
      "Output": "App is OK!\n"
    },
    {
      "Start": "2020-12-07T14:02:38.271698843Z",
      "End": "2020-12-07T14:02:38.414782397Z",
      "ExitCode": 0,
      "Output": "App is OK!\n"
    }
  ]
}
```
