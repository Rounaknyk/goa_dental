class GetInitials{
  String name;
  GetInitials(this.name);

  get(){
    return name.substring(0, 1);
  }

}