# rails-gitlab-k8s
Template for rails app to be deployable on kubernetes via gitlab-ci

```bash
  curl -L https://github.com/kypp/rails-gitlab-k8s/archive/master.tar.gz | tar xz --strip-components 1
```
to the main rails directory and push to GitLab.

---

Included are:
- two-stage production Dockerfile for optimal image size
- docker-compose for development
- webpacker handling for development and production
- automatic kubernetes deployment based on GitLab's autodevops

---

To ensure that kubernetes can access the GitLab Docker registry after deployment (for scaling or handling pod/node failure):

1. Go to project on GitLab -> Settings -> Repository -> Deploy Tokens
2. Create a deploy token with **read_registry** scope
3. Go to Settings -> CI / CD -> Secret variables
4. Insert two variables KUBE_REGISTRY_USER and KUBE_REGISTRY_PASSWORD containing credentials of the deploy token

This will probably get automated a few GitLab versions ahead.
