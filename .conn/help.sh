help(){
  if [ $1 = "add" ]; then echo help add; exit 1; fi
  if [ $1 = "folder" ]; then echo help folder; exit 1; fi
  if [ $1 = "folder-add" ]; then echo help folder add; exit 1; fi
  if [ $1 = "folder-del" ]; then echo help folder del; exit 1; fi
  if [ $1 = "folder-ren" ]; then echo help folder rename; exit 1; fi
  if [ $1 = "profile" ]; then echo help profile; exit 1; fi
  if [ $1 = "profile-add" ]; then echo help profile add; exit 1; fi
  if [ $1 = "profile-del" ]; then echo help profile del; exit 1; fi
  if [ $1 = "profile-edit" ]; then echo help profile edit; exit 1; fi
  if [ $1 = "del" ]; then echo help del; exit 1; fi
  if [ $1 = "edit" ]; then echo help edit; exit 1; fi
  if [ $1 = "ren" ]; then echo help ren; exit 1; fi
  if [ $1 = "edit" ]; then echo help edit; exit 1; fi
  if [ $1 = "global" ]; then echo help global; exit 1; fi
}
