{pkgs, ...}: let
  commentablefmt =
    pkgs.writers.writePython3Bin "commentablefmt" {
      libraries = [pkgs.python3Packages.pytablewriter];
    } ''
      from pytablewriter import MarkdownTableWriter
      import sys
      import json


      def main():
          jsondata = json.load(sys.stdin)
          writer = MarkdownTableWriter(
            table_name="Matrix",
            headers=["package", "x86_64-linux", "x86_64-darwin", "aarch64-darwin"],
            value_matrix=jsondata
          )
          writer.write_table()


      if __name__ == "__main__":
          main()
    '';
in
  pkgs.mkShellNoCC {
    packages = with pkgs; [
      just
      jq
      nix-eval-jobs
      commentablefmt
    ];
  }
