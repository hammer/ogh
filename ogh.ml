let gh_user = Sys.getenv "GITHUB_USER"
let gh_pass = Sys.getenv "GITHUB_PASSWORD"

let ask_github fn = Github.(Monad.run (fn ()))

let print_repo_info m =
  let open Printf in
  let open Github_t in
  eprintf "repo %s: %s (%d watchers, %d open issues)\n%!"
          m.repo_name m.repo_description m.repo_watchers m.repo_open_issues

let get_token cookie_name =
  let open Lwt in
  Github_cookie_jar.init () >>= fun ghcj ->
  Github_cookie_jar.get ghcj ~name:"ogh" >>= fun auth ->
  return (Github.Token.of_auth (BatOption.get auth))

(* This code assumes you have already gotten the token
   and saved it locally in your cookie jar *)
let t =
  let open Lwt in
  get_token "ogh" >>= fun token ->
  ask_github (Github.Repo.info ~token ~user:"hammer" ~repo:"ogh") >|=
  print_repo_info >>= fun () ->
  ask_github (Github.Repo.info ~token ~user:"hammer" ~repo:"ocass") >|=
  print_repo_info >>= fun () ->
  return ()

let _ = Lwt_main.run t

