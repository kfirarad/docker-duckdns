FROM curlimages/curl

# Launch script that runs updater and loops
COPY launch.sh /
ENTRYPOINT ["/launch.sh"]
