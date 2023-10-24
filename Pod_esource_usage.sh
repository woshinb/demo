#!/bin/bash
container_name="container_name"

log_file="container_stats.log"

while true; do
    timestamp=$(date "+%Y-%m-%d %H:%M:%S")

    cpu_stats=$(docker stats --no-stream $container_name --format "{{.CPUPerc}}")

    mem_stats=$(docker stats --no-stream $container_name --format "{{.MemUsage}}")

    echo "$timestamp - CPU: $cpu_stats, Memory: $mem_stats" >> $log_file

    sleep 10
done
