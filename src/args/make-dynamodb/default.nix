# SPDX-FileCopyrightText: 2022 Fluid Attacks and Makes contributors
#
# SPDX-License-Identifier: MIT
{
  makeScript,
  __nixpkgs__,
  managePorts,
  fetchUrl,
  toBashArray,
  makeTerraformEnvironment,
  ...
}: {
  name,
  host ? "127.0.0.1",
  port ? "8022",
  data ? [],
  dataDerivation ? [],
  infra ? "",
  daemonMode ? false,
  ...
}: let
  dbData = data ++ dataDerivation;
  hasInfra = (__nixpkgs__.lib.strings.stringLength infra) > 0;
in
  makeScript {
    name = "dynamodb-for-${name}";
    replace = {
      __argPort__ = port;
      __argHost__ = host;
      __argDynamoZip__ = fetchUrl {
        url = "https://s3-us-west-2.amazonaws.com/dynamodb-local/dynamodb_local_2021-02-08.zip";
        sha256 = "01xgqk2crrnpvzr3xkd3mwiwcs6bfxqhbbyard6y8c0jgibm31pk";
      };
      __argData__ = toBashArray dbData;
      __argShouldPopulate__ = builtins.length dbData > 0;
      __argInfra__ = infra;
      __argDaemonMode__ = daemonMode;
    };
    searchPaths = {
      bin =
        [
          __nixpkgs__.openjdk_headless
          __nixpkgs__.unzip
          __nixpkgs__.awscli
        ]
        ++ (
          if hasInfra
          then [
            __nixpkgs__.awscli
          ]
          else []
        );
      source =
        [
          managePorts
        ]
        ++ (
          if hasInfra
          then [
            (makeTerraformEnvironment {
              version = "1.0";
            })
          ]
          else []
        );
    };
    entrypoint = ./entrypoint.sh;
  }
