#!/bin/bash

tar -czvf app-backup.tar.gz /var/www/html
mysqldump migration_demo > migration_demo.sql
