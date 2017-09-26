# Plugins

Go to:

```
git checkout step-7
```

## Steps

1\. We will try Godaddy

https://github.com/n3integration/terraform-godaddy

bash <(curl -s https://raw.githubusercontent.com/n3integration/terraform-godaddy/master/install.sh)

```
variable "godaddy_key" {}
variable "godaddy_secret" {}
```

```
godaddy_key    = ""
godaddy_secret = ""
```

```
provider "godaddy" {
  key = "abc"
  secret = "123"
}
```

```
resource "godaddy_domain_record" "acme" {
  domain   = "phpun.org"

  record {
    name = "@"
    type = "A"
    data = "50.63.202.50"
    ttl = 600
  }

  record {
    name = "www"
    type = "CNAME"
    data = "@"
    ttl = 3600
  }

  record {
    name = "acme"
    type = "CNAME"
    data = "${aws_elb.acme.dns_name}"
    ttl = 300
  }

  nameservers = ["ns11.domaincontrol.com", "ns12.domaincontrol.com"]
}

```

```
terraform init
terraform get
terraform plan
terraform apply
```

*Because godaddy is an special provider this is not in the main branch `git checkout plugin-godaddy`*

Use `terraform state rm godaddy_domain_record.acme` if you are planning to go back to the main branch.
