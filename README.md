# lightsail-setup
Scripts used to set up the lightsail instance

## Code Of Conduct

- Only use dist.sh for production build
- For beta testing, either create a new branch or create a beta-VERSION.sh file in master branch
- Feel free to create scratch-VERSION.sh files

## Usage

- Copy and Paste this code and wait for the success message.
```bash
 curl https://raw.githubusercontent.com/nativerank/nr-instance-setup/master/dist.sh | bash -s -- --dev-slug=devsite_slug --site-url=www.DOMAIN.com
```

- Make sure you replace **www.DOMAIN.com** with your domain &  **devsite_slug** with your slug

