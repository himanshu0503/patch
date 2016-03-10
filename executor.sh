declare -a os=('u12')
declare -a languages=('nod')
declare -a languageVersions=('')

level="base"
CURRENT_FILE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

build_image(){
  osVersion=$1
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
  create_patch_file "$CURRENT_FILE_DIR/os/$osVersion"
  #append language specific patch
  create_patch_file "$CURRENT_FILE_DIR/languages/$lang"

  #append imaage specific patch
  if [ -d "$CURRENT_FILE_DIR/language/$lang" ]; then
    if [ -f "$CURRENT_FILE_DIR/language/$lang/$os$lang$langVer.sh" ]; then
      echo `cat $CURRENT_FILE_DIR/language/$lang/$os$lang$langVer.sh` >> patch.sh
    fi
  fi

  create_docker_file "$osVersion" "$lang" "$langVer"

  docker build -t="drydock/$os$lang$langVer:prod" $CURRENT_FILE_DIR
}

create_patch_file() {
  path=$1
  if [ -d "$path" ]; then
    if [ -f "$path/base-patch.sh" ]; then
      echo `cat $path/base-patch.sh` >> patch.sh
    fi

    if [ "$level" == "pls" ] || [ "$level" == "all" ]; then
      if [ -f "$path/pls-patch.sh" ]; then
        echo `cat $path/pls-patch.sh` >> patch.sh
      fi
    fi

    if [ "$level" == "all" ];then
      if [ -f "$path/all-patch.sh" ]; then
        echo `cat $path/all-patch.sh` >> patch.sh
      fi
    fi
  fi
}

create_docker_file() {
  osVersion=$1
  lang=$2
  langVer=$3

  if [ -f "$CURRENT_FILE_DIR/Dockerfile" ]; then
    rm $CURRENT_FILE_DIR/Dockerfile
  fi

  touch $CURRENT_FILE_DIR/Dockerfile

  echo "FROM drydock/$os$lang$langVer:marker" >> Dockerfile
  echo "ADD ./patch.sh /$os$lang$langVer/patch.sh" >> Dockerfile
  echo "RUN ./$os$lang$langVer/patch.sh" >> Dockerfile
}


for osVersion in "${os[@]}"
  do
    for language in "${languages[@]}"
      do
        for languageVersion in "${languageVersions[@]}"
         do
            build_image "$osVersion" "$language" "$languageVersion"
         done
      done
  done
