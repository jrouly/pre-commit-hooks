FILES=${@:1}

java -jar pre_commit_hooks/google_java_format/google-java-format-1.3-all-deps.jar $FILES
