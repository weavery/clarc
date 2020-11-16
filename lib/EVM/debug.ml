(* This is free and unencumbered software released into the public domain. *)

let print_debug ppf program =
  let open Format in
  let jumpdest_to_block jumpdest_pc =
    let rec loop pc = function
      | [] -> None
      | block :: _ when pc = jumpdest_pc -> Some block
      | (_, block_body) :: blocks ->
        loop (pc + opcodes_size block_body) blocks
    in
    loop 0 program
  in
  let print_op pc = function
    | PUSH (1, byte_value) as op ->
      let decimal_value = Char.code (String.get byte_value 0) in
      fprintf ppf "%04x: %s (%d)\n" pc (to_string op) decimal_value
    (* TODO: | PUSH (n, _) *)
    | op -> fprintf ppf "%04x: %s\n" pc (to_string op)
  in
  let print_push_jumpdest pc op =
    match jumpdest_to_block pc with
    | None -> fprintf ppf "%04x: %s (?)\n" pc (to_string op)
    | Some (block_id, _) -> fprintf ppf "%04x: %s (#%d)\n" pc (to_string op) block_id
  in
  let rec dump_block pc = function
    | [] -> ()
    | (block_id, block_body) :: blocks ->
      let rec dump_opcode pc = function
        | [] -> pc
        | (PUSH (1, jumpdest) as op1) :: (JUMPI as op2) :: ops ->
          let jumpdest_pc = Char.code (String.get jumpdest 0) in
          print_push_jumpdest jumpdest_pc op1;
          let pc = pc + (opcode_size op1) in
          print_op pc op2;
          let pc = pc + (opcode_size op2) in
          dump_opcode pc ops
        (* TODO: | PUSH (n, _) *)
        | op :: ops ->
          print_op pc op;
          let pc = pc + (opcode_size op) in
          dump_opcode pc ops
      in
      fprintf ppf "#%d\n" block_id;
      let pc = dump_opcode pc block_body in
      dump_block pc blocks
  in
  dump_block 0 program
