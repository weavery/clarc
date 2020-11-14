(* This is free and unencumbered software released into the public domain. *)

let print_debug ppf program =
  let open Format in
  let rec dump_block pc = function
    | [] -> ()
    | (block_id, block_body) :: blocks ->
      let rec dump_opcode pc = function
        | [] -> pc
        | op :: ops ->
          fprintf ppf "%04x: %s\n" pc (to_string op);
          let pc = pc + (opcode_size op) in
          dump_opcode pc ops
      in
      fprintf ppf "#%d\n" block_id;
      let pc = dump_opcode pc block_body in
      dump_block pc blocks
  in
  dump_block 0 program
