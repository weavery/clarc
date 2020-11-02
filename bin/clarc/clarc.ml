(* This is free and unencumbered software released into the public domain. *)

open Cmdliner

let version = "0.5.0"  (* TODO: preprocess from VERSION *)

exception Error of int * string * string

let clarc verbose paths output target _optimize _features =
  let _fprintf = Format.fprintf in

  let eprintf = if Unix.isatty (Unix.descr_of_out_channel stderr)
    then Ocolor_format.eprintf
    else Format.eprintf
  in

  let output_channel =
    match output with None -> stdout | Some output_path -> open_out output_path
  in

  let output_formatter = Format.formatter_of_out_channel output_channel in

  let printf (format : ('a, Format.formatter, unit) format) : 'a =
    if Unix.isatty (Unix.descr_of_out_channel output_channel)
    then
      let formatter' = Ocolor_format.make_formatter output_formatter in
      Format.fprintf (Ocolor_format.unwrap_formatter formatter') format
    else Format.fprintf output_formatter format
  in

  let read_file path =
    let channel = open_in path in
    let contents = really_input_string channel (in_channel_length channel) in
    close_in channel;
    contents
  in

  let guess_target = function
    | None -> None
    | Some output -> begin match Filename.extension output with
        | ".bin" -> Some Target.Bytecode
        | ".opcode" -> Some Target.Opcode
        | _ -> None
      end
  in

  let rec process_program program target =
    match target with
    | Target.Auto -> begin match guess_target output with
        | Some target -> process_program program target
        | None -> printf "@[<v>%a@]@?" Clarity.print_program program
      end
    | Bytecode ->
      let (deployer, program) = Clar2EVM.compile_contract program in
      let program = deployer @ program in
      let printf = Format.fprintf output_formatter in
      printf "@[<h>%a@]@." EVM.print_program_as_bytecode program
    | Opcode ->
      let (deployer, program) = Clar2EVM.compile_contract program in
      let program = deployer @ program in
      let printf = Format.fprintf output_formatter in
      printf "@[<hov>%a@]@." EVM.print_program_as_opcode program
  in

  let process_file path =
    if verbose then eprintf "@{<yellow>Compiling %s...@}@." path;
    let input = read_file path in
    let program = Clarity.parse_program input in
    process_program program target
  in

  try `Ok (List.iter process_file paths)
  with Error (code, path, error) -> begin
    eprintf "@{<red>error:@} %s: %s@." path error;
    exit code
  end

let command =
  let doc = "compile Clarity contracts for Ethereum" in
  let man = [
    `S Manpage.s_description;
    `P "$(tname) compiles Clarity contracts into Ethereum virtual machine (EVM) bytecode.";
    `S Manpage.s_bugs; `P "Report any bugs at <https://github.com/weavery/clarc/issues>." ]
  in
  Term.(ret (const clarc $ Options.verbose $ Options.files $ Options.output $ Options.target $ Options.optimize $ Options.features)),
  Term.info "clarc" ~version ~doc ~exits:Term.default_exits ~man

let () = Term.(exit @@ eval command)
