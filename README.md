# Patch
Patch repo for drydock images

# File Hierarchy

#### global dir (patches which will be applied to all the images)
Can contain three files
* base-patch.sh (Applied on all the images. ex- u12, u14nod, u12phpall).
* pls-patch.sh (Applied only to pls and all images. ex- u12nodpls, u14nodall).
* all-patch.sh (Applied only to all images. ex - u12nodall, u14nodall).

#### os dir (patches specific to u12 and u14 operating systems)
Each of u12 and u14 folder can contain three files.
* base-patch.sh (Applied on all the images. ex- u12, u12nod, u12phpall).
* pls-patch.sh (Applied only to pls and all images. ex- u12nodpls, u12nodall).
* all-patch.sh (Applied only to all images. ex - u12nodall, u12nodall).

#### languages dir (patches specific to the eight images supported by shippable - node, python, java, scala, php, go, ruby, clojure)
Each of the eight can contain three files.
* base-patch.sh (Applied on all the images. ex- u12, u14nod, u12nodall).
* pls-patch.sh (Applied only to pls and all images. ex- u12nodpls, u14nodall).
* all-patch.sh (Applied only to all images. ex - u12nodall, u14nodall).

Apart from that if an image requires additional patches we will have a file called `$osVer$lang$langVer-patch.sh`. The location of this file will be inside `/languages/$lang`.

# Usage
The executor.sh function contains three arrays `os, languages and languageVersions` which all determine which all images are to be patched. Values for these three arrays are as follows
* os - 'u12' 'u14'
* languages - '' 'nod' 'pyt' 'php' 'rub' 'gol' 'clo' 'jav' 'sca' ('' is for the base images u12, u14)
* languageVersions - '' 'pls' 'all'

To patch an image we need to add the files in the following order.
* If patch is to be applied globally then add the patch in global folder (also check if the patch is to be placed in base-patch.sh, pls-patch.sh or all-patch.sh).
* If patch is to be applied at an OS level then add the patch in `os/$osVer` folder (also check if the patch is to be placed in base-patch.sh, pls-patch.sh or all-patch.sh).
* If patch is to be applied at an Language level then add the patch in `languages/$lang` folder (also check if the patch is to be placed in base-patch.sh, pls-patch.sh or all-patch.sh).
* If patch is only specific to the image then add the patch in `languages/$lang` and name the file as `$osVer$lang$langVer-patch.sh`.

# Example
* Patching every image - add base-patch.sh in global dir and inside `executor.sh` set all the values in `os, languages, languageVersions` array.
* Patching pls images - add pls-patch.sh in global dir and inside `executor.sh` set all the values in `os, languages` array. The value in `languageVersions` array should be `pls`.
* Patching u12nodpls image - add u12nodpls-patch.sh in languages/nod and inside `executor.sh` set the array values of `os as 'u12'`, `languages as 'nod'` and `languageVersions as 'pls'`.

# Note
* `base-patch.sh` is applied to `base, pls and all` images so we should not include the same patch in `pls-patch.sh and all-patch.sh`.
* `pls-patch.sh` is applied to `pls and all` images so we should not include the same patch in `all-patch.sh`.
