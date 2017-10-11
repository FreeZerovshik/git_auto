REM Получить комиты день назад
git log --oneline --graph --name-only --after="1 day ago"
git log --oneline --graph --name-only --after="yesterday"

REM комиты за сегодня
git log --oneline --graph --name-only --after="today"

rem вывод комитов коментариев
git log --pretty=format:"%h $ad- %s [%an]"