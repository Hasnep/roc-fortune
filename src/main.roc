app "fortune"
    packages {
        cli: "https://github.com/roc-lang/basic-cli/releases/download/0.7.1/Icc3xJoIixF3hCcfXrDwLCu4wQHtNdPyoJkEbkgIElA.tar.br",
    }
    imports [cli.Stdout, cli.Env, cli.Task, cli.Path, cli.Utc, cli.File, cli.Stderr]
    provides [main] to cli

pathAppend : Path.Path, Str -> Path.Path
pathAppend = \p, s -> p |> Path.display |> Str.concat "/" |> Str.concat s |> Path.fromStr

getConfigFolder : Task.Task Path.Path _
getConfigFolder =
    getXdgConfigHome = Env.var "XDG_CONFIG_HOME" |> Task.map Path.fromStr
    getHome = Env.var "HOME" |> Task.map Path.fromStr
    getXdgConfigHome
    |> Task.onErr (\_ -> getHome |> Task.map (\h -> h |> pathAppend ".config"))
    |> Task.mapErr (\_ -> CouldntGetConfigFolder)

readFortunesFile : Path.Path -> Task.Task Str [CouldntReadFortunesFile Path.Path]
readFortunesFile = \fortunesFilePath ->
    fortunesFilePath
    |> File.readUtf8
    |> Task.mapErr (\_ -> CouldntReadFortunesFile fortunesFilePath)

getPseudoRandomNatBelow : Nat -> Task.Task Nat *
getPseudoRandomNatBelow = \max ->
    utc <- Utc.now |> Task.map
    utc
    |> Utc.toMillisSinceEpoch
    |> Num.divTrunc 1_000_000_000
    |> Num.rem (max |> Num.toU128)
    |> Num.toNat

getRandomFortune : List Str -> Task.Task Str *
getRandomFortune = \fortunes ->
    nFortunes = List.len fortunes
    randomIndex <- getPseudoRandomNatBelow nFortunes |> Task.await
    fortunes |> List.get randomIndex |> Result.withDefault "" |> Task.ok

main : Task.Task {} I32
main =
    task =
        configFolder <- getConfigFolder |> Task.await
        fortunesFilePath = configFolder |> pathAppend "roc-fortune" |> pathAppend "fortunes.txt"
        fortunesStr <- readFortunesFile fortunesFilePath |> Task.await
        fortunes = fortunesStr |> Str.split "\n" |> List.keepIf (\f -> f |> Str.isEmpty |> Bool.not)
        getRandomFortune fortunes
    result <- Task.attempt task
    when result is
        Ok fortune -> Stdout.line fortune |> Task.mapErr (\_ -> 0)
        Err CouldntGetConfigFolder -> Stderr.line "Couldn't get config folder :(" |> Task.mapErr (\_ -> 1)
        Err (CouldntReadFortunesFile p) -> Stderr.line "Couldn't read fortunes file \(Path.display p) :(" |> Task.mapErr (\_ -> 2)
