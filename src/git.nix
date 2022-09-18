{ pkgs }:

let
  gitConfig = pkgs.writeTextFile {
    name = "ec-linux-workspace-gitconfig";
    destination = "/.gitconfig";
    text = builtins.readFile ./../files/home/gitconfig;
  };
in pkgs.symlinkJoin
  {
    name = "git";
    buildInputs = [ pkgs.makeWrapper ];
    paths = [ pkgs.git ];
    postBuild = ''
      wrapProgram "$out/bin/git" --set HOME "${gitConfig}"
    '';
  }
