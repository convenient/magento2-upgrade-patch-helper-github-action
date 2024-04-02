TODO

Need to add instructions and examples

- dump your stores / websites / themes to `app/etc/config.php` so theme analysis can be done.
- This can be modified so that it works on demand, or automatically on dependabot
    - By splitting the process into two dockerfiles we can lazy load one, saving gitub action runtime and allowing for early exit on unnecessary dependabot PRs
- Explain auth.json for building private authentication 