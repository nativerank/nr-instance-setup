# lightsail-setup
Scripts used to set up the lightsail instance


## Usage

- Copy and Paste this code and wait for the success message.

| :warning: Make sure you replace **www.DOMAIN.com** with your domain  |
| --- |
```bash
 curl https://raw.githubusercontent.com/nativerank/nr-instance-setup/master/dist.sh | bash -s -- --site-url=www.DOMAIN.com
```

## Additional options
| option | description |
| --------|:-----------:|
| --dev-slug=DEVSITE-SLUG | replace DEVSITE-SLUG with devsite slug to override the value from wp options |
| --skip-pagespeed | do not optimize pagespeed config file |
| --skip-redis | do not install redis-server |


## Development

### Code Of Conduct

- Only use dist.sh for production build
- For beta testing, either create a new branch or create a beta-VERSION.sh file in master branch
- Feel free to create scratch-VERSION.sh files
