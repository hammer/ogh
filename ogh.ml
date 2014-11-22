let gh_user = Sys.getenv "GITHUB_USER"
let gh_pass = Sys.getenv "GITHUB_PASSWORD"

(* This code assumes you have already gotten the token
   and saved it locally in your cookie jar *)
let t =
  lwt ghcj = Github_cookie_jar.init () in
  lwt auth = Github_cookie_jar.get ghcj ~name:"ogh" in
  let token = Github.Token.of_auth (BatOption.get auth) in
  prerr_endline (Github.Token.to_string token);
  Lwt.return ()

let _ = Lwt_main.run t

