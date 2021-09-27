ssh-keygen -t ed25519 -C "bucket.size@gmail.com"
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519

cat ~/.ssh/id_ed25519.pub


# $ git remote add origin https://github.com/user/repo.git
# # Set a new remote

# $ git remote -v
# # Verify new remote
# > origin  https://github.com/user/repo.git (fetch)
# > origin  https://github.com/user/repo.git (push)
