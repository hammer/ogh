open Lwt
open Printf
open Github_t

let gh_user = Sys.getenv "GITHUB_USER"
let gh_pass = Sys.getenv "GITHUB_PASSWORD"

(* This code assumes you have already gotten the token
   and saved it locally in your cookie jar *)
let t =
  lwt r =
    lwt ghcj = Github_cookie_jar.init () in
    lwt auth = Github_cookie_jar.get ghcj ~name:"ogh" in
    let token = Github.Token.of_auth (BatOption.get auth) in
    let open Github.Monad in
    run (
    Github.Repo.info ~token ~user:"hammer" ~repo:"ogh" () >>=
    fun info ->
      eprintf "Description of ogh repo: %s\n" info.repo_description;
      return ()
      ) in
  return ()

let _ = Lwt_main.run t

