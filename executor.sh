declare -a os=('u12' 'u14')
declare -a languages=('' 'nod' 'pyt' 'php' 'rub' 'gol' 'clo' 'jav' 'sca')
declare -a languageVersions=('' 'pls' 'all')

level="base"
should_push=true
CURRENT_FILE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
TEST_PASSED_IMAGES=()
TEST_FAILED_IMAGES=()

build_image() {
  osVer=$1
  lang=$2
  langVer=$3

  if [ "$langVer" == "pls" ]; then
    level="pls"
  fi

  if [ "$langVer" == "all" ]; then
    level="all"
  fi

  if [ -f "$CURRENT_FILE_DIR/patch.sh" ]; then
    rm $CURRENT_FILE_DIR/patch.sh
  fi

  touch $CURRENT_FILE_DIR/patch.sh
  chmod +x $CURRENT_FILE_DIR/patch.sh

  #append global level patch
  create_patch_file "$CURRENT_FILE_DIR/global"
  #append os specific patch
  create_patch_file "$CURRENT_FILE_DIR/os/$osVer"
  #append language specific patch
  create_patch_file "$CURRENT_FILE_DIR/languages/$lang"

  #append image specific patch
  if [ -d "$CURRENT_FILE_DIR/language/$lang" ]; then
    if [ -f "$CURRENT_FILE_DIR/language/$lang/$osVer$lang$langVer-patch.sh" ]; then
      cat $CURRENT_FILE_DIR/language/$lang/$osVer$lang$langVer-patch.sh >> patch.sh
    fi
  fi

  create_patch_test_dir "$osVer" "$lang" "$langVer"

  create_docker_file "$osVer" "$lang" "$langVer"

  docker build -t="drydock/$osVer$lang$langVer:prod" $CURRENT_FILE_DIR
}

create_patch_file() {
  path=$1
  if [ -d "$path" ]; then
    if [ -f "$path/base-patch.sh" ]; then
      cat $path/base-patch.sh >> patch.sh
    fi

    if [ "$level" == "pls" ] || [ "$level" == "all" ]; then
      if [ -f "$path/pls-patch.sh" ]; then
        cat $path/pls-patch.sh >> patch.sh
      fi
    fi

    if [ "$level" == "all" ];then
      if [ -f "$path/all-patch.sh" ]; then
        cat $path/all-patch.sh >> patch.sh
      fi
    fi
  fi
}

create_patch_test_dir() {
  osVer=$1
  lang=$2
  langVer=$3

  if [ -d "$CURRENT_FILE_DIR/patch_test" ];then
    rm -r $CURRENT_FILE_DIR/patch_test
  fi

  if [ "$lang" != "" ] || [ "$langVer" != "" ]; then
    mkdir $CURRENT_FILE_DIR/patch_test
    if [ "$lang" != "" ];then
      cp $CURRENT_FILE_DIR'/tests/languages/'$lang'.sh' $CURRENT_FILE_DIR/'patch_test'
      cp $CURRENT_FILE_DIR'/tests/languages/executor.sh' $CURRENT_FILE_DIR/'patch_test'
    fi
    # Run only pls and all tests if language is not present and services exist
    if [ "$langVer" != "" ] && [ "$lang" == "" ];then
      cp $CURRENT_FILE_DIR/'tests/'$langVer/* $CURRENT_FILE_DIR/'patch_test'
    fi
  fi
}

create_docker_file() {
  osVer=$1
  lang=$2
  langVer=$3

  if [ -f "$CURRENT_FILE_DIR/Dockerfile" ]; then
    rm $CURRENT_FILE_DIR/Dockerfile
  fi

  touch $CURRENT_FILE_DIR/Dockerfile

  echo "FROM drydock/$osVer$lang$langVer:marker" >> Dockerfile
  echo "ADD ./patch.sh /$osVer$lang$langVer/patch.sh" >> Dockerfile
  echo "ADD ./patch_test /$osVer$lang$langVer/patch_test" >> Dockerfile
  echo "RUN ./$osVer$lang$langVer/patch.sh" >> Dockerfile
}

test_image() {

  if [ "$lang" != "" ] || [ "$langVer" != "" ]; then
    echo 'Starting tests for image -----> '$osVer$lang$langVer
    #run the commands in a daemon mode
    containerId=$(docker run -d drydock/$osVer$lang$langVer':prod' /bin/bash -c "/$osVer$lang$langVer/patch_test/executor.sh")
    exitCode=$(docker wait $containerId)

    #commands failed inside container
    if [ "$exitCode" != 0 ];then
      echo 'Tests failed for image -----> '$osVer$lang$langVer
      should_push=false
      TEST_FAILED_IMAGES+=("$osVer$lang$langVer")
      docker logs $containerId
    else
      echo 'All tests passed for image -----> '$osVer$lang$langVer
      TEST_PASSED_IMAGES+=("$osVer$lang$langVer")
    fi
  else
    echo 'Skipping tests for image -----> '$osVer$lang$langVer
    TEST_PASSED_IMAGES+=("$osVer$lang$langVer")
  fi
}

clear_files() {
  if [ -d "$CURRENT_FILE_DIR/patch_test" ];then
    rm -r $CURRENT_FILE_DIR/patch_test
  fi

  if [ -f "$CURRENT_FILE_DIR/patch.sh" ]; then
    rm $CURRENT_FILE_DIR/patch.sh
  fi

  if [ -f "$CURRENT_FILE_DIR/Dockerfile" ]; then
    rm $CURRENT_FILE_DIR/Dockerfile
  fi

  level="base"
  should_push=true
}

display_results() {
  if [ ${#TEST_PASSED_IMAGES[@]} != 0 ];then
    echo "<====================== PASSED IMAGES =======================>"
    for passedImage in "${TEST_PASSED_IMAGES[@]}"
      do
        echo $passedImage
      done
    echo "<============================================================>"
  fi
  if [ ${#TEST_FAILED_IMAGES[@]} != 0 ];then
    echo "<====================== FAILED IMAGES =======================>"
    for failedImage in "${TEST_FAILED_IMAGES[@]}"
      do
        echo $failedImage
      done
    echo "<============================================================>"
  fi
}

for osVer in "${os[@]}"
  do
    for lang in "${languages[@]}"
      do
        for langVer in "${languageVersions[@]}"
         do
            build_image "$osVer" "$lang" "$langVer"
            test_image
            # if [ "$should_push" = true ];then
            #   docker push 'drydock/'$osVer$lang$langVer
            # fi
            clear_files
         done
      done
  done

display_results
