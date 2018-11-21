resource "aws_key_pair" "acme" {
    key_name   = "acme"
    public_key = "${file(var.ssh_pubkey_path)}"
}
