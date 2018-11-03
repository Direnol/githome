# Githome

# Техническое задание
Необходимо создать аналог GitHub/GitLab, для возможность частного использования и более удобного обращения к инструментам, которые предоставляет система контроля версий git.

## Обоснование проекта
Есть множество подобных сервисов (gitweb cgit Gitblit ViewGit Klaus и т.д. подробнее можно почитать на сайте http://yourcmc.ru/wiki/Git_веб-интерфейсы) но все они имеют ряд особенностей которые не позволяют применить их для домашнего использования, такие как:
- сложность установки и настройки,
- много лишних для домашнего использования функций,
- тяжеловесность и т.п.

## Особенности реализации
### Обязательные фичи
- Наличие Веб интерфейса с возможность создания и просмотра репозиториев
- Просмотр отдельных файлов и коммитов(diff)
- Наличие авторизации и аутентификации пользователей
- Создание групповых проектов
### Желательно иметь
- Возможность работы c репозиторием посредством ssh ключей
- Просмотр истории коммитов в виде дерева

## Зависимости

* Ubuntu 14.04/16.04/17.04/18.04 or Debian 7/8/9
* Add Erlang Solutions repo: `wget https://packages.erlang-solutions.com/erlang-solutions_1.0_all.deb && sudo dpkg -i erlang-solutions_1.0_all.deb`
* Run: `sudo apt-get update`
* Install the Erlang/OTP platform and all of its applications: `sudo apt-get install esl-erlang`
* Install Elixir: `sudo apt-get install elixir`


To start your Phoenix server:

* Install dependencies with `mix deps.get`
* Create and migrate your database with `mix ecto.create && mix ecto.migrate`
* Install Node.js dependencies with `cd assets && npm install`
* Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](http://www.phoenixframework.org/docs/deployment).

## Learn more

* Official website: http://www.phoenixframework.org/
* Guides: http://phoenixframework.org/docs/overview
* Docs: https://hexdocs.pm/phoenix
* Mailing list: http://groups.google.com/group/phoenix-talk
* Source: https://github.com/phoenixframework/phoenix
