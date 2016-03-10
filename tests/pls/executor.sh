CURRENT_FILE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

for file in $CURRENT_FILE_DIR/*;
  do
    if [ "$file" != "$CURRENT_FILE_DIR/executor.sh" ] && [ "$file" != "$CURRENT_FILE_DIR/function_start_generic.sh" ];
      then
        /bin/bash $file
    fi
  done
