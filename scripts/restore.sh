#!/bin/bash

tar -xzvf app-backup.tar.gz -C /

mysql -e "DROP DATABASE IF EXISTS migration_demo; CREATE DATABASE migration_demo;"
mysql migration_demo < migration_demo.sql
