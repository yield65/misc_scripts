# Sender Policy Framework

### Background

Using an SPF record in our DNS servers we can:
* Reduce or eliminate the SPAM messages that spammers send using our domain names or mail addresses
* Improve the effectiveness of our mail filters with policies that accept or reject messages filtering the SPF record, within our domains, subdomains or third parties domains
* Reduce or eliminate the probability of our domain being blacklisted in SPAM lists

### Setting up
We need to set the SPF record on our DNS servers specifying the mail servers that can send emails in behalf of our domain. This also includes the slave DNS servers.

The SPF record always start with v=spf1 then we include the SMTP servers that send the mail messages in behalf of our domain, it can be an IPv6, IPv4 or a network mask, as many as we need.

In the next example we will tell other MTA's that our domain example.com only sends email through 192.168.2.25 and any message that use another SMTP should be considered as SPAM by the recipient.

**SPF record example**
```
"v=spf1 ip4:192.168.2.25 include:_spf.example.com -all"
```

This is how a header of a mail message with a valid SPF record looks like

**Header valid SPF**
```
Received-SPF: pass (recipient.com: domain of username@example.com designates 192.168.2.25 as permitted sender) client-ip=192.168.1.38;
```
This is a header of a mail message with an invalid SPF record

**Header with invalid SPF**
```
Received-SPF: softfail (recipient.com: domain of transitioning username@example.com does not designate 117.247.211.154 as permitted sender) client-ip=117.247.211.154;
```

**Possible security policies**
* We can create a security policy in our mail service infrastructure to only allow mail messages with a valid SPF record in the header, this can be done using a mail gateway or with matching strings


# DomainKeys Identified Mail

### Background
DKIM records allows a company or an individual with a personal domain to create a trusted email communication channel between costumers or other companies because every mail message we sent is digitally signed by our SMTP server and the receiver MTA can verify the message against our public signature specified in our DKIM record of our DNS server.

DKIM realiza dos funciones, firma de los correos enviados y verificación de firma en los correos entrantes.

DKIM is a two step process, the first step is our SMTP server signing every message we send using a private key on the server and the second step is the MTA of the recipient that verifies the validity of this signature against our DNS servers (authoritative and slaves).

DKIM can only be configured after a successful SPF configuration.

It is very important to properly configure DKIM because only then we will be able to set up the next step which is the setup of DMARC rules.

It is plausible that even with an SPF record configured, an attacker can forge with a chain of mail relays a message than can get through a filter using a "soft fail" result in it's header and getting into a user's inbox, but with DKIM, if the signature doesn't match, it's 100% sure it's spam.

Summarizing, the use of DKIM consists of two records, one is configured in our SMTP server (private key), the second is configured in our DNS server (public key)

**Header with valid DKIM**
```
DKIM-Signature: v=1; a=rsa-sha256; d=example.net; s=brisbane;
     c=relaxed/simple; q=dns/txt; l=1234; t=1117574938; x=1118006938;
     h=from:to:subject:date:keywords:keywords;
     bh=MTIzNDU2Nzg5MDEyMzQ1Njc4OTAxMjM0NTY3ODkwMTI=;
     b=dzdVyOfAKCdLXdJOc9G2q8LoXSlEniSbav+yuU4zGeeruD00lszZ
              VoG4ZHRNiYzR
```
```
Authentication-Results: mail.dominio.com;
       dkim=pass header.i=@example.net;
       spf=pass (example.net: domain of username@example.net designates 192.168.2.25 as permitted sender) smtp.mailfrom=username@example.net
```
Here we see how the recipient's MTA checks the SPF record and then it verifies our DKIM signature which is a RSA-SHA256 unique per server and domain.

**Possible Security policies**
* Setup filters to prioritize those mail messages which SPF and DKIM records get a possitive verification
* Setup filters for mail messages that only complies with SPF and not DKIM
* Create filters to store those messages without SPF and/or DKIM records in a separate user inbox folder
* Create filters to Quarantine inside a SPAM folder or to just reject all messages that fail the SPF or DKIM tests

# Domain-based Message Authentication, Reporting and Conformance (DMARC)

### Background
DMARC policies are configured in the DNS servers, these policies tell the MTA what to do with messages that doesn't succeed in verification of their SPF _and_ their DKIM records.

According to DMARC standard, there are three possible policies to apply based on the results of the verification of the records: none, quarantine and reject. These policies are enforced by the MTA.

An end user can configure the mail client application to filter messages based on the results of the verification method (either SPF or DKIM) which are stored on the mail message header but the DMARC policies have to be enforced by the MTA.

If one of the records on the mail message is invalid then the DMARC result is considered as failed and we have the option to inform the sender the reason of the rejection of the message. This can also be configured on the DMARC record at our DNS server.

Using DMARC policies we can enforce trusted email channels to other companies to reduce spoofed or spam email messages.

***DMARC header from trusted source***
```
Authentication-Results: mx.google.com;
       dkim=pass header.i=@example.com;
       spf=pass (google.com: domain of sender@example.com designates 2607:f8b0:400e:c00::22a as permitted sender) smtp.mailfrom=sender@2example.com;
       dmarc=pass (p=NONE dis=NONE) header.from=example.com
```
***DMARC header from utrusted source***
```
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning unknown@example.com does not designate 117.247.211.154 as permitted sender) smtp.mailfrom=unknown@example.com;
       dmarc=fail (p=NONE dis=NONE) header.from=example.com
```
**Possible security policies**

There are three types of policies to apply to failed results according to DMARC verification:

    1. None
    2. Quarantine
    3. Reject

It is recommended to begin with "none", then "quarantine" and then "reject".
