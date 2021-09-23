{ __nixpkgs__
, makeScript
, toFileJson
, ...
}:
{ attempts ? 1
, attemptDurationSeconds
, command
, environment ? [ ]
, definition
, memory
, queue
, name
, setup ? [ ]
, vcpus
}:
makeScript {
  name = "compute-on-aws-batch-for-${name}";
  replace = {
    __argAttempts__ = attempts;
    __argAttemptDurationSeconds__ = attemptDurationSeconds;
    __argCommand__ = toFileJson "command.json" command;
    __argDefinition__ = definition;
    __argManifest__ = toFileJson "manifest.json" {
      environment = builtins.concatLists [
        [{ name = "CI"; value = "true"; }]
        (builtins.map
          (name: { inherit name; value = "\${${name}}"; })
          (environment))
      ];
      inherit memory;
      inherit vcpus;
    };
    __argName__ = name;
    __argQueue__ = queue;
  };
  searchPaths = {
    bin = [
      __nixpkgs__.awscli
      __nixpkgs__.envsubst
      __nixpkgs__.jq
    ];
    source = setup;
  };
  entrypoint = ./entrypoint.sh;
}