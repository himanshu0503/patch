declare -a os=('u12' 'u14')
declare -a languages=('' 'nod' 'pyt' 'gol' 'clo' 'jav' 'sca' 'php' 'rub')
declare -a languageVersions=('' 'pls' 'all')

for osVersion in "${os[@]}"
  do
    for language in "${languages[@]}"
      do
        for languageVersion in "${languageVersions[@]}"
          do
            docker pull 'drydock/'$osVersion$language$languageVersion':prod'
            docker tag -f 'drydock/'$osVersion$language$languageVersion':prod' 'drydock/'$osVersion$language$languageVersion':marker'
            docker push 'drydock/'$osVersion$language$languageVersion':marker'
            echo '<========================== Pushed drydock/'$osVersion$language$languageVersion':marker ==========================>'
          done
      done
  done
