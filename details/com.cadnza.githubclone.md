# About

Lightning fast and super secure `git clone` for Github. :fast_forward: Lists your public and private repositories for cloning into your Repos directory, wherever it happens to be. :file_folder:

![](https://raw.githubusercontent.com/cadnza/Alfred.alfredpreferences/master/workflows/user.workflow.962B6B49-7B12-4A17-A833-D84ED9C13D7B/demo/demo.gif)

# Configuration

1. This workflow lists private repositories as well as public, so first thing you need is a [personal access token](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token). :key: Be sure to give it [full access to the repo scope](https://docs.github.com/en/developers/apps/building-oauth-apps/scopes-for-oauth-apps#available-scopes).
2. Once you have your access token, save it in a [keychain](https://support.apple.com/guide/mac-help/use-keychains-to-store-passwords-mchlf375f392/mac). There are a couple of ways to do this:
    - **Via [Keychain Access](https://support.apple.com/guide/keychain-access/what-is-keychain-access-kyca1083/mac)** :computer:
        1. Open Keychain Access.
        2. Optionally (but recommended), create a new keychain with _File > New Keychain..._. Give your keychain a nice name and save it in the default location, i.e. `~/Library/Keychains/`.
        3. Create a new password item with _File > New Password Item..._. Paste your personal access token in the _Password_ field, and take note of the _Keychain Item Name_ field.
    - **Via [`security`](https://ss64.com/osx/security.html)** :pager:
        1. Run the following commands, replacing variables as appropriate:
			- `security create-keychain`
			- `security add-internet-password -s serviceNameHere -a accountNameHere keychainNameHere`
			- The account name is of little consequence; it's just a convenient identifier to help you find the key.
			- The service name _is_ of consequence; that's what Github Clone uses to find your personal access token. By default, Github Clone looks for a service called `https://api.github.com/`, but that's configurable (keep reading).
3. Open the workflow in Alfred and set the following [Workflow Environment Variables](https://www.alfredapp.com/help/workflows/advanced/variables/#environment): :pencil:
    - `githubUsername`: The username associated with your Github account.
    - `keychain`: The name of your keychain _file_. If you're unsure, check in the location where you created the keychain.
        - If you saved to the default location or created your keychain through `security`, your keychain will be in `~/Library/Keychains/`.
        - Note that you want the filename, not the path.
    - `openOnClone`: Set this variable to `1` if you want repositories to open in Finder on clone. Any other value will clone without opening.
    - `reposDirectory`: Where you want to clone repos.
    - `service`: The service name of your personal access token in the keychain. If you don't remember, open Keychain Access and find the item containing your personal access token for details.
    - `useSSH`: Set this variable to `1` to clone repos via [SSH](https://github.com/git-guides/git-clone#git-clone-with-ssh). Any other value clones repos via default HTTPS using your personal access token.
4. And you're ready to go! :fist:

# So how does it work?

Here's how Github Clone for Alfred is _lightning fast_ and _super secure_: :muscle:

## Lightning Fast

Querying your repos and parsing the returned JSON takes time, so Github Clone creates an index and updates it passively as you use the workflow. The reindexing routine only runs when you call Github Clone from Alfred, and it's inactive otherwise, so you'll never see it eating resources or making random network calls. :satellite:

## Super Secure

Your Github personal access token is basically another password to your Github account. By accessing it through [`security`](https://ss64.com/osx/security.html), Github Clone never exposes it as plain text. And Github Clone's index is fully encrypted with [`openssl`](https://www.openssl.org/)'s [Triple DES](https://en.wikipedia.org/wiki/Triple_DES) implementation using your Github personal access token, so it's off-limits outside Github Clone. :lock:

# That's all?

Yep. Happy cloning! :floppy_disk:

# Versions

## v1.1.1

-   Fix early termination bug

## v1.1.0

-   Validate connnection to Github

## v1.0.0

-   First release
