(* This is free and unencumbered software released into the public domain. *)

open Cmdliner

let verbose =
  let doc = "Be verbose." in
  Arg.(value & flag & info ["v"; "verbose"] ~doc)

let files =
  Arg.(value & pos_all non_dir_file ["/dev/stdin"] & info [] ~docv:"FILE")

let output =
  let doc = "Specify the output file." in
  Arg.(value & opt (some string) None & info ["o"; "output"] ~docv:"OUTPUT" ~doc)

let target =
  let output_format =
    let parse = Target.of_string in
    let print ppf p = Target.to_string p |> Format.fprintf ppf "%s" in
    Arg.conv ~docv:"TARGET" (parse, print)
  in
  let doc = "Specify the output format: `auto', `bytecode', `opcode'." in
  Arg.(value & opt output_format Target.Auto & info ["t"; "target"] ~docv:"TARGET" ~doc)

let optimize =
  let doc = "Specify the optimization level to use." in
  Arg.(value & opt int 0 & info ["O"; "optimize"] ~docv:"LEVEL" ~doc)

let features =
  let feature_flag =
    let parse = Feature.of_string in
    let print ppf p = Feature.to_string p |> Format.fprintf ppf "%s" in
    Arg.conv ~docv:"FLAG" (parse, print)
  in
  let doc = "Specify optional feature flags: `no-deploy'." in
  Arg.(value & opt_all feature_flag [Feature.None] & info ["f"; "feature"] ~docv:"FLAG" ~doc)
