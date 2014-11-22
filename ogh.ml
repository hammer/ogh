let t =
  let gh_user = Sys.getenv "GITHUB_USER" in
  let gh_pass = Sys.getenv "GITHUB_PASSWORD" in
  let r = Github.Token.create ~user:gh_user ~pass:gh_pass ~note:"get_token via ocaml-github" () in
  lwt auth = Github.Monad.run r in
  let token = Github.Token.of_auth auth in
  prerr_endline (Github.Token.to_string token);
  Lwt.return ()

let _ = Lwt_main.run t

