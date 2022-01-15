[[onion_routing]]
== Onion Routing

((("onion routing", id="ix_10_onion_routing-asciidoc0", range="startofrange")))In this chapter we will describe the Lightning Network's onion routing mechanism. The invention of _onion routing_ precedes the Lightning Network by 25 years! Onion routing was invented by U.S. Navy researchers as a communications security protocol. Onion routing is most famously used by Tor, the onion-routed internet overlay that allows researchers, activists, intelligence agents, and everyone else to use the internet privately and anonymously.

In this chapter we are focusing on the "Source-based onion routing (SPHINX)" part of the Lightning protocol architecture, highlighted by an outline in the center (routing layer) of <<LN_protocol_onion_highlight>>. 

[[LN_protocol_onion_highlight]]
.Onion routing in the Lightning protocol suite
image::images/mtln_1001.png["Onion routing in the Lightning protocol suite"]

Onion routing describes a method of encrypted communication where a message sender builds successive _nested layers of encryption_ that are "peeled" off by each intermediary node, until the innermost layer is delivered to the intended recipient. The name "onion routing" describes this use of layered encryption that is peeled off one layer at a time, like the skin of an onion.

Each of the intermediary nodes can only "peel" one layer and see who is next in the communication path. Onion routing ensures that no one except the sender knows the destination or length of the communication path. Each intermediary only knows the previous and next hop.

The Lightning Network uses an implementation of onion routing protocol based on pass:[<em>Sphinx</em>],footnote:[George Danezis and Ian Goldberg, "Sphinx: A Compact and Provably Secure Mix Format," in _IEEE Symposium on Security and Privacy_ (New York: IEEE, 2009), 269–282.] developed in 2009 by George Danezis and Ian Goldberg.

The implementation of onion routing in the Lightning Network is defined in https://github.com/lightningnetwork/lightning-rfc/blob/master/04-onion-routing.md[BOLT #4: Onion Routing Protocol].

=== A Physical Example Illustrating Onion Routing

((("onion routing","physical example", id="ix_10_onion_routing-asciidoc1", range="startofrange")))There are many ways to describe onion routing, but one of the easiest is to use the physical equivalent of sealed envelopes. An envelope represents a layer of encryption, allowing only the named recipient to open it and read the contents.

Let's say Alice wants to send a secret letter to Dina, indirectly via some intermediaries.

==== Selecting a Path

((("onion routing","selecting a path")))The Lightning Network uses _source routing_, which means that the payment path is selected and specified by the sender, and only the sender. In this example, Alice's secret letter to Dina will be the equivalent of a payment. To make sure the letter reaches Dina, Alice will create a path from her to Dina, using Bob and Chan as intermediaries.

[TIP]
====
There may be many paths that make it possible for Alice to reach Dina. We will explain the process of selecting the _optimum_ path in <<path_finding>>. For now, we'll assume that the path selected by Alice uses Bob and Chan as intermediaries to get to Dina.
====

[role="pagebreak-before"]
As a reminder, the path selected by Alice is shown in <<alice_dina_path>>. 

[[alice_dina_path]]
.Path: Alice to Bob to Chan to Dina
image::images/mtln_1002.png["Alice to Bob to Chan to Dina"]

Let's see how Alice can use this path without revealing information to intermediaries Bob and Chan.

.Source-Based Routing
****
((("source-based routing")))Source-based routing is not how packets are typically routed on the internet today, though source routing was possible in the early days.
Internet routing is based on _packet switching_ at each intermediary routing node. An IPv4 packet, for example, includes the sender and recipient's IP addresses, and every other IP routing node decides how to forward each packet toward the destination.
However, the lack of privacy in such a routing mechanism, where every intermediary node sees the sender and recipient, makes this a poor choice for use in a payment network.
****

==== Building the Layers

((("onion routing","building the layers", id="ix_10_onion_routing-asciidoc2", range="startofrange")))Alice starts by writing a secret letter to Dina.  She then seals the letter inside an envelope and writes "To Dina" on the outside (see <<dina_envelope>>). The envelope represents encryption with Dina's public key so that only Dina can open the envelope and read the letter.

[[dina_envelope]]
.Dina's secret letter, sealed in an envelope
image::images/mtln_1003.png["Dina's secret letter, sealed in an envelope"]

Dina's letter will be delivered to Dina by Chan, who is immediately before Dina in the "path." So, Alice puts Dina's envelope inside an envelope addressed to Chan (see <<chan_envelope>>). The only part that Chan can read is the destination (routing instructions): "To Dina." Sealing this inside an envelope addressed to Chan represents encrypting it with Chan's public key so that only Chan can read the envelope address. Chan still can't open Dina's envelope. All he sees is the instructions on the outside (the address).

[[chan_envelope]]
.Chan's envelope, containing Dina's sealed envelope
image::images/mtln_1004.png["Chan's envelope, containing Dina's sealed envelope"]

Now, this letter will be delivered to Chan by Bob. So Alice puts it inside an envelope addressed to Bob (see <<bob_envelope>>). As before, the envelope represents a message encrypted to Bob that only Bob can read. Bob can only read the outside of Chan's envelope (the address), so he knows to send it to Chan.

[[bob_envelope]]
.Bob's envelope, containing Chan's sealed envelope
image::images/mtln_1005.png["Bob's envelope, containing Chan's sealed envelope"]

Now, if we could look through the envelopes (with X-rays!) we would see the envelopes nested one inside the other, as shown in <<nested_envelopes>>. (((range="endofrange", startref="ix_10_onion_routing-asciidoc2")))

[[nested_envelopes]]
.Nested envelopes
image::images/mtln_1006.png[Nested envelopes]

==== Peeling the Layers

((("onion routing","peeling the layers")))Alice now has an envelope that says "To Bob" on the outside. It represents an encrypted message that only Bob can open (decrypt). Alice will now begin the process by sending this to Bob. The entire process is shown in <<sending_nested_envelopes>>. 

[[sending_nested_envelopes]]
.Sending the envelopes
image::images/mtln_1007.png[Sending the envelopes]

As you can see, Bob receives the envelope from Alice. He knows it came from Alice, but doesn't know if Alice is the original sender or just someone forwarding envelopes. He opens it to find an envelope inside that says "To Chan." Since this is addressed to Chan, Bob can't open it. He doesn't know what's inside it and doesn't know if Chan is getting a letter or another envelope to forward. Bob doesn't know if Chan is the ultimate recipient or not. Bob forwards the envelope to Chan.

Chan receives the envelope from Bob. He doesn't know that it came from Alice. He doesn't know if Bob is an intermediary or the sender of a letter. Chan opens the envelope and finds another envelope inside addressed "To Dina," which he can't open. Chan forwards it to Dina, not knowing if Dina is the final recipient.

Dina receives an envelope from Chan. Opening it she finds a letter inside, so now she knows she's the intended recipient of this message. She reads the letter, knowing that none of the intermediaries know where it came from and no one else has read her secret letter!

This is the essence of onion routing. The sender wraps a message in layers, specifying exactly how it will be routed and preventing any of the intermediaries from gaining any information about the path or payload. Each intermediary peels one layer, sees only a forwarding address, and doesn't know anything other than the previous and next hop in the path.

Now, let's look at the details of the onion routing implementation in the Lightning Network.(((range="endofrange", startref="ix_10_onion_routing-asciidoc1")))

=== Introduction to Onion Routing of HTLCs

((("hash time-locked contracts (HTLCs)","onion routing basics", id="ix_10_onion_routing-asciidoc3", range="startofrange")))((("onion routing","HTLCs", id="ix_10_onion_routing-asciidoc4", range="startofrange")))Onion routing in the Lightning Network appears complex at first glance, but once you understand the basic concept, it is really quite simple.

From a practical perspective, Alice is telling every intermediary node what HTLC to set up with the next node in the path.

((("origin node")))The first node, which is the payment sender or Alice in our example, is called the _origin node_.  ((("final node")))The last node, which is the payment recipient or Dina in our example, is called the _final node_.

((("hop")))Each intermediary node, or Bob and Chan in our example, is called a _hop_. Every hop must set up an _outgoing HTLC_ to the next hop. The information communicated to each hop by Alice is called the _hop payload_ or _hop data_. The message that is routed from Alice to Dina is called an _onion_ and consists of encrypted _hop payload_ or _hop data_ messages encrypted to each hop.

Now that we know the terminology used in Lightning onion routing, let's restate Alice's task: Alice must construct an onion with hop data, telling each hop how to construct an outgoing HTLC to send a payment to the final node (Dina).

==== Alice Selects the Path

((("onion routing","selecting a path")))From <<routing>> we know that Alice will send a 50,000 satoshi payment to Dina via Bob and Chan. This payment is transmitted via a series of HTLCs, as shown in <<alice_dina_htlc_path>>. 

[[alice_dina_htlc_path]]
.Payment path with HTLCs from Alice to Dina
image::images/mtln_1008.png[Payment path with HTLCs from Alice to Dina]

As we will see in <<gossip>>, Alice is able to construct this path to Dina because Lightning nodes announce their channels to the entire Lightning Network using the Lightning Gossip Protocol. After the initial channel announcement, Bob and Chan each sent out an additional `channel_update` message with their routing fee and timelock expectations for payment routing.

From the announcements and updates, Alice knows the following information about the channels between Bob, Chan, and Dina:

* A +short_channel_id+ (short channel ID) for each channel, which Alice can use to reference the channel when constructing the path

* A +cltv_expiry_delta+ (timelock delta), which Alice can add to the expiry time for each HTLC

* A +fee_base_msat+ and +fee_proportional_millionths+, which Alice can use to calculate the total routing fee expected by that node for relay on that channel.

In practice, other information is also exchanged, such as the largest (`htlc_maximum_msat`) and smallest (`htlc_minimum_msat`) HTLCs a channel will carry, but these aren't used as directly during onion route construction as the preceding fields are.

This information is used by Alice to identify the nodes, channels, fees, and timelocks for the following detailed path, shown in <<alice_dina_path_detail>>. 

[[alice_dina_path_detail]]
.A detailed path constructed from gossiped channel and node information
image::images/mtln_1009.png[A path constructed from gossiped channel and node information]

Alice already knows her own channel to Bob and therefore doesn't need this info to construct the path. Note also that Alice didn't need a channel update from Dina because she has the update from Chan for that last channel in the path.

==== Alice Constructs the Payloads

((("onion routing","payload construction", id="ix_10_onion_routing-asciidoc5", range="startofrange")))There are two possible formats that Alice can use for the information communicated to each hop: ((("hop data")))a legacy fixed-length format called the _hop data_ and a more flexible Type-Length-Value (TLV) based format called the _hop payload_. The TLV message format is explained in more detail in <<tlv>>. It offers flexibility by allowing fields to be added to the protocol at will.

[NOTE]
====
Both formats are specified in https://github.com/lightningnetwork/lightning-rfc/blob/master/04-onion-routing.md#packet-structure[BOLT #4: Onion Routing Protocol, Packet Structure].
====

Alice will start building the hop data from the end of the path backwards: Dina, Chan, then Bob.

===== Final node payload for Dina

((("final node")))Alice first builds the payload that will be delivered to Dina. Dina will not be constructing an "outgoing HTLC," because Dina is the final node and payment recipient. For this reason, the payload for Dina is different than all the others (uses all zeros for the `short_channel_id`), but only Dina will know this because it will be encrypted in the innermost layer of the onion. Essentially, this is the "secret letter to Dina" we saw in our physical envelope example.

The hop payload for Dina must match the information in the invoice generated by Dina for Alice and will contain (at least) the following fields in TLV format:

+amt_to_forward+:: The amount of this payment in millisatoshis. If this is only one part of a multipart payment, the amount is less than the total. Otherwise, this is a single, full payment and it is equal to the invoice amount and +total_msat+ value.

+outgoing_cltv_value+:: The payment expiry timelock set to the value +min_final_cltv_expiry+ in the invoice.

+payment_secret+:: A special 256-bit secret value from the invoice, allowing Dina to recognize this incoming payment. This also prevents a class of probing that previously made zero-value invoices insecure. Probing by intermediate nodes is mitigated as this value is encrypted to _only_ the recipient, meaning they can't reconstruct a final packet that "looks" legitimate.

+total_msat+:: The total amount matching the invoice. This may be omitted if there is only one part, in which case it is assumed to match +amt_to_forward+ and must equal the invoice amount.

The invoice Alice received from Dina specified the amount as 50,000 satoshis, which is 50,000,000 millisatoshis. Dina specified the minimum expiry for the payment +min_final_cltv_expiry+ as 18 blocks (3 hours, given 10-minute on average Bitcoin blocks). At the time Alice is attempting to make the payment, let's say the Bitcoin blockchain has recorded 700,000 blocks. So Alice must set the +outgoing_cltv_value+ to a _minimum_ block height of 700,018.

((("hop payload", id="ix_10_onion_routing-asciidoc6", range="startofrange")))Alice constructs the hop payload for Dina as follows:

----
amt_to_forward : 50,000,000
outgoing_cltv_value: 700,018
payment_secret: fb53d94b7b65580f75b98f10...03521bdab6d519143cd521d1b3826
total_msat: 50,000,000
----

Alice serializes it in TLV format, as shown (simplified) in <<dina_onion_payload>>. 

[[dina_onion_payload]]
.Dina's payload is constructed by Alice
image::images/mtln_1010.png[Dina's payload is constructed by Alice]

===== Hop payload for Chan

Next, Alice constructs the hop payload for Chan. This will tell Chan how to set up an outgoing HTLC to Dina.

The hop payload for Chan includes three fields: +short_channel_id+, +amt_to_forward+, and +outgoing_cltv_value+:

----
short_channel_id: 010002010a42be
amt_to_forward: 50,000,000
outgoing_cltv_value: 700,018
----

Alice serializes this payload in TLV format, as shown (simplified) in <<chan_onion_payload>>. 

[[chan_onion_payload]]
.Chan's payload is constructed by Alice
image::images/mtln_1011.png[Chan's payload is constructed by Alice]

===== Hop payload for Bob

Finally, Alice constructs the hop payload for Bob, which also contains the same three fields as the hop payload for Chan, but with different values:

----
short_channel_id: 000004040a61f0
amt_to_forward: 50,100,000
outgoing_cltv_value: 700,038
----

As you can see, the +amt_to_forward+ field is 50,100,000 millisatoshis, or 50,100 satoshis. That's because Chan expects a fee of 100 satoshis to route a payment to Dina. In order for Chan to "earn" that routing fee, Chan's incoming HTLC must be 100 satoshis more than Chan's outgoing HTLC. Since Chan's incoming HTLC is Bob's outgoing HTLC, the instructions to Bob reflect the fee Chan earns. In simple terms, Bob needs to be told to send 50,100 satoshi to Chan, so that Chan can send 50,000 satoshi and keep 100 satoshi.

Similarly, Chan expects a timelock delta of 20 blocks. So Chan's incoming HTLC must expire 20 blocks _later_ than Chan's outgoing HTLC. To achieve this, Alice tells Bob to make his outgoing HTLC to Chan expire at block height 700,038-20 blocks later than Chan's HTLC to Dina.

[TIP]
====
Fees and timelock delta expectations for a channel are set by the difference between incoming and outgoing HTLCs. Since the incoming HTLC is created by the _preceding node_, the fee and timelock delta is set in the onion payload to that preceding node. Bob is told how to make an HTLC that meets Chan's fee and timelock expectations.
====

Alice serializes this payload in TLV format, as shown (simplified) in <<bob_onion_payload>>. 

[[bob_onion_payload]]
.Bob's payload is constructed by Alice
image::images/mtln_1012.png[Bob's payload is constructed by Alice]

===== Finished hop payloads

Alice has now built the three hop payloads that will be wrapped in an onion. A simplified view of the payloads is shown in <<onion_hop_payloads>>.(((range="endofrange", startref="ix_10_onion_routing-asciidoc6"))) (((range="endofrange", startref="ix_10_onion_routing-asciidoc5")))

[[onion_hop_payloads]]
.Hop payloads for all the hops
image::images/mtln_1013.png[Hop payloads for all the hops]

[role="pagebreak-before less_space"]
==== Key Generation

((("keys","generating for onion routing", id="ix_10_onion_routing-asciidoc7", range="startofrange")))((("keys","onion routing and", id="ix_10_onion_routing-asciidoc8", range="startofrange")))((("onion routing","key generation", id="ix_10_onion_routing-asciidoc9", range="startofrange")))Alice must now generate several keys that will be used to encrypt the various layers in the onion.

With these keys, Alice can achieve a high degree of privacy and integrity:

* Alice can encrypt each layer of the onion so that only the intended recipient can read it.
* Every intermediary can check that the message is not modified.
* No one in the path will know who sent this onion or where it is going. Alice doesn't reveal her identity as the sender or Dina's identity as the recipient of the payment.
* Each hop only learns about the previous and next hop.
* No one can know how long the path is, or where  in the path they are.

[WARNING]
====
Like a chopped onion, the following technical details may bring tears to your eyes. Feel free to skip to the next section if you get confused. Come back to this and read https://github.com/lightningnetwork/lightning-rfc/blob/master/04-onion-routing.md#packet-construction[BOLT #4: Onion Routing, Packet Construction], if you want to learn more.
====


((("shared secret (ss)")))The basis for all the keys used in the onion is a _shared secret_ that Alice and Bob can both generate independently using the Elliptic Curve Diffie–Hellman (ECDH) algorithm. From the shared secret (ss), they can independently generate four additional keys named ++rho++, ++mu++, ++um++, and ++pad++:

++rho++:: Used to generate a stream of random bytes from a stream cipher (used as a
CSPRNG). These bytes are used to encrypt/decrypt the message body as well as
filler zero bytes during Sphinx packet processing.

++mu++:: Used in the hash-based message authentication code (HMAC) for integrity/authenticity verification.

++um++:: Used in error reporting.

++pad++:: Used to generate filler bytes for padding the onion to a fixed length.

The relationship between the various keys and how they are generated is diagrammed in <<onion_keygen>>. 

[[onion_keygen]]
.Onion key generation
image::images/mtln_1014.png[Onion Key Generation]

[[session_key]]
===== Alice's session key

((("session key")))To avoid revealing her identity, Alice does not use her own node's public key in building the onion. Instead, Alice creates a temporary 32-byte (256-bit) key called the _session private key_ and corresponding _session public key_. This serves as a temporary "identity" and key _for this onion only_. From this session key, Alice will build all the other keys that will be used in this onion.

[[keygen_details]]
===== Key generation details
The key generation, random byte generation, ephemeral keys, and how they are used in packet construction are specified in three sections of BOLT #4:

* https://github.com/lightningnetwork/lightning-rfc/blob/master/04-onion-routing.md#key-generation[Key Generation]
* https://github.com/lightningnetwork/lightning-rfc/blob/master/04-onion-routing.md#pseudo-random-byte-stream[Random Byte Stream]
* https://github.com/lightningnetwork/lightning-rfc/blob/master/04-onion-routing.md#packet-construction[Packet Construction]

For simplicity and to avoid getting too technical, we have not included these details in the book. See the preceding links if you want to see the inner workings.

[[shared_secret]]
===== Shared secret generation

((("shared secret (ss)")))One important detail that seems almost magical is the ability for Alice to create a _shared secret_ with another node simply by knowing their public keys. ((("Diffie-Hellman Key Exchange (DHKE)", id="ix_10_onion_routing-asciidoc10", range="startofrange")))This is based on the invention of Diffie–Hellman key exchange (DH) in the 1970s that revolutionized cryptography. Lightning onion routing uses Elliptic Curve Diffie–Hellman (ECDH) on Bitcoin's +secp256k1+ curve. It's such a cool trick that we try to explain it in simple terms in <<ecdh_explained>>. 


// To editor: Maybe put this in an appendix instead of a sidebar?

[[ecdh]]
[[ecdh_explained]]
.Elliptic Curve Diffie–Hellman Explained
****
((("ECDH (Elliptic Curve Diffie–Hellman)")))((("Elliptic Curve Diffie–Hellman (ECDH)")))Assume Alice's private key is _a_ and Bob's private key is _b_. Using the elliptic curve, Alice and Bob each multiply their private key by the generator point _G_ to produce their public keys _A_ and _B_, respectively:

++++
<ul class="simplelist">
<li><em>A</em> = <em>aG</em></li>
<li><em>B</em> = <em>bG</em></li>
</ul>
++++

Now Alice and Bob can use _Elliptic Curve Diffie–Hellman Key Exchange_ to create a shared secret _ss_, a value that they can both calculate independently without exchanging any information

The shared secret _ss_ is calculated by each by multiplying their own private key with the _other's_ public key, such that:

++++
<ul class="simplelist">
<li><em>ss</em> = <em>aB</em> = <em>bA</em></li>
</ul>
++++

But why would these two multiplications result in the same value _ss_?
Follow along, as we demonstrate the math that proves this is possible:

++++
<ul class="simplelist">
<li><em>ss</em></li>
<li>= <em>aB</em></li>
</ul>
++++

calculated by Alice who knows both _a_ (her private key) and _B_ (Bob's public key)

++++
<ul class="simplelist">
<li>= <em>a</em>(<em>bG</em>)</li>
</ul>
++++

because we know that _B_ = _bG_, we substitute

++++
<ul class="simplelist">
<li> = (<em>ab</em>)<em>G</em></li>
</ul>
++++

because of associativity, we can move the parentheses

++++
<ul class="simplelist">
<li>= (<em>ba</em>)<em>G</em></li>
</ul>
++++

because _xy_ = _yx_ (the curve is an abelian group)

++++
<ul class="simplelist">
<li>= <em>b</em>(<em>aG</em>)</li>
</ul>
++++

because of associativity, we can move the parentheses

++++
<ul class="simplelist">
<li>= <em>bA</em></li>
</ul>
++++

and we can substitute _aG_ with _A_.

The result _bA_ can be calculated independently by Bob who knows _b_ (his private key) and _A_ (Alice's public key).

We have therefore shown that:

++++
<ul class="simplelist">
<li><em>ss</em> = <em>aB</em> (Alice can calculate this)</li>
<li><em>ss</em> = <em>bA</em> (Bob can calculate this)</li>
</ul>
++++

Thus, they can each independently calculate _ss_ which they can use as a shared key to symmetrically encrypt secrets between the two of them without communicating the shared secret.(((range="endofrange", startref="ix_10_onion_routing-asciidoc10")))

****

A unique trait of Sphinx as a mix-net packet format is that rather than include a distinct session key for each hop in the route, which would increase the size of the mix-net packet dramatically, ((("blinding scheme")))a clever _blinding_ scheme is used to deterministically randomize the session key at each hop.

In practice, this little trick allows us to keep the onion packet as compact as possible while still retaining the desired security properties.

The session key for hop `i` is derived using the node public key, and derived shared secret of hop `i – 1`:
```
session_key_i = session_key_{i-1} * SHA-256(node_pubkey_{i-1} || shared_secret_{i-1})
```

In other words, we take the session key of the prior hop, and multiply it by a value derived from the public key and the derived shared secret for that hop.

As elliptic curve multiplication can be performed on a public key without knowledge of the private key, each hop is able to re-randomize the session key for the next hop in a deterministic fashion.

The creator of the onion packet knows all the shared secrets (as they've encrypted the packet uniquely for each hop), and thus are able to derive all the blinding factors.

This knowledge allows them to derive all the session keys used up front during packet generation.

Note that the very first hop uses the original session key generated because this key is used to kick off the session key blinding by each subsequent hop(((range="endofrange", startref="ix_10_onion_routing-asciidoc9")))(((range="endofrange", startref="ix_10_onion_routing-asciidoc8")))(((range="endofrange", startref="ix_10_onion_routing-asciidoc7"))).(((range="endofrange", startref="ix_10_onion_routing-asciidoc4")))(((range="endofrange", startref="ix_10_onion_routing-asciidoc3")))


[[wrapping_the_onion]]
=== Wrapping the Onion Layers

((("onion routing","wrapping the onion layers", id="ix_10_onion_routing-asciidoc11", range="startofrange")))The process of wrapping the onion is detailed in https://github.com/lightningnetwork/lightning-rfc/blob/master/04-onion-routing.md#packet-construction[BOLT #4: Onion Routing, Packet Construction].

In this section we will describe this process at a high and somewhat simplified level, omitting certain details.


[[fixed_length_onions]]
==== Fixed-Length Onions

((("onion routing","fixed-length onions")))We've mentioned the fact that none of the "hop" nodes know how long the path is, or where they are in the path. How is this possible?

If you have a set of directions, even if encrypted, can't you tell how far you are from the beginning or end simply by looking at _where_ in the list of directions you are?

The trick used in onion routing is to always make the path (the list of directions) the same length for every node. This is achieved by keeping the onion packet the same length at every step.

At each hop, the hop payload appears at the beginning of the onion payload, followed by _what seem to be_ 19 more hop payloads. Every hop sees itself as the first of 20 hops.

[TIP]
====
The onion payload is 1,300 bytes. Each hop payload is 65 bytes or less (padded to 65 bytes if less). So the total onion payload can fit 20 hop payloads (1300 = 20 &times; 65). The maximum onion routed path is therefore 20 hops.
====

As each layer is "peeled off," more filler data (essentially junk) is added at the end of the onion payload so the next hop gets an onion of the same size and is once again the "first hop" in the onion.

The onion size is 1,366 bytes, structured as shown in <<onion_packet>>: 

1 byte:: A version byte
33 bytes:: A compressed public session key (<<session_key>>) from which the per-hop shared secret (<<shared_secret>>) can be generated without revealing Alice's identity
1,300 bytes:: The actual _onion payload_ containing the instructions for each hop
32 bytes:: An HMAC integrity checksum

[[onion_packet]]
.The onion packet
image::images/mtln_1015.png[]

A unique trait of Sphinx as a mix-net packet format is that rather than include a distinct session key for each hop in the route, which would increase the size of the mix-net packet dramatically, instead a clever _blinding_ scheme is used to deterministically randomize the session key at each hop.

In practice, this little trick allows us to keep the onion packet as compact as possible while still retaining the desired security properties.

==== Wrapping the Onion (Outlined)

((("onion routing","outline of wrapping process")))Here is the process of wrapping the onion, outlined next. Come back to this list as we explore each step with our real-world example.

For each hop, the sender (Alice) repeats the same process:

1. Alice generates the per-hop shared secret and the ++rho++, ++mu++, and ++pad++ keys.

2. Alice generates 1,300 bytes of filler and fills the 1,300-byte onion payload field with this filler.

3. Alice calculates the HMAC for the hop payload (zeros for the final hop).

4. Alice calculates the length of the hop payload + HMAC + space to store the length itself.

5. Alice _right-shifts_ the onion payload by the calculated space needed to fit the hop payload. The rightmost "filler" data is discarded, making enough space on the left for the payload.

6. Alice inserts the length + hop payload + HMAC at the front of the payload field in the space made from shifting the filler.

7. Alice uses the ++rho++ key to generate a 1,300-byte one-time pad.

8. Alice obfuscates the entire onion payload by XORing with the bytes generated from ++rho++.

9. Alice calculates the HMAC of the onion payload, using the ++mu++ key.

10. Alice adds the session public key (so that the hop can calculate the shared secret).

11. Alice adds the version number.

12. Alice deterministically re-blinds the session key using a value derived by hashing the shared secret and prior hop's public key.

Next, Alice repeats the process. The new keys are calculated, the onion payload is shifted (dropping more junk), the new hop payload is added to the front, and the whole onion payload is encrypted with the ++rho++ byte stream for the next hop.

For the final hop, the HMAC included in Step #3 over the plain-text instructions is actually _all zero_.
The final hop uses this signal to determine that it is indeed the final hop in the route.
Alternatively, the fact that the `short_chan_id` included in the payload to denote the "next hop" is all zero can be used as well.

Note that at each phase the ++mu++ key is used to generate an HMAC over the _encrypted_ (from the point of view of the node processing the payload) onion packet, as well as over the contents of the packet with a single layer of encryption removed.
This outer HMAC allows the node processing the packet to verify the integrity of the onion packet (no bytes modified).
The inner HMAC is then revealed during the inverse of the "shift and encrypt" routine described previously, which serves as the _outer_ HMAC for the next hop.

==== Wrapping Dina's Hop Payload

((("onion routing","wrapping hop payloads", id="ix_10_onion_routing-asciidoc12", range="startofrange")))As a reminder, the onion is wrapped by starting at the end of the path from Dina, the final node or recipient. Then the path is built in reverse all the way back to the sender, Alice.

Alice starts with an empty 1,300-byte field, the fixed-length _onion payload_. Then, she fills the onion payload with a pseudorandom byte stream "filler" that is generated from the ++pad++ key.

This is shown in <<onion_payload_filler>>. 

[NOTE]
====
Random byte stream generation uses the ChaCha20 algorithm, as a cryptographic secure pseudorandom number generator (CSPRNG). Such an algorithm will generate a deterministic, long, nonrepeating stream of seemingly random bytes from an initial seed. The details are specified in https://github.com/lightningnetwork/lightning-rfc/blob/master/04-onion-routing.md#pseudo-random-byte-stream[BOLT #4: Onion Routing, Pseudo Random Byte Stream].
====

[[onion_payload_filler]]
.Filling the onion payload with a random byte stream
image::images/mtln_1016.png[]

Alice will now insert Dina's hop payload into the left side of the 1,300-byte array, shifting the filler to the right and discarding anything that overflows. This is visualized in <<onion_add_dina>>. 

[[onion_add_dina]]
.Adding Dina's hop payload
image::images/mtln_1017.png[]

Another way to look at this is that Alice measures the length of Dina's hop payload, shifts the filler right to create an equal space in the left side of the onion payload, and inserts Dina's payload in that space.

Next row down we see the result: the 1,300 byte onion payload contains Dina's hop payload and then the filler byte stream filling up the rest of the space.

Next, Alice obfuscates the entire onion payload so that _only Dina_ can read it.

To do this, Alice generates a byte stream using the ++rho++ key (which Dina also knows). Alice uses a bitwise exclusive or (XOR) between the bits of the onion payload and the byte stream created from ++rho++. The result appears like a random (or encrypted) byte stream of 1,300 bytes length. This step is shown in <<onion_obfuscate_dina>>. 

[[onion_obfuscate_dina]]
.Obfuscating the onion payload
image::images/mtln_1018.png[]

One of the properties of XOR is that if you do it twice, you get back to the original data. As we will see in <<bobDeobfuscates>>, if Dina applies the same XOR operation with the byte stream generated from ++rho++, it will reveal the original onion payload.

[TIP]
====
XOR is an _involutory_ function, which means that if it is applied twice, it undoes itself. Specifically XOR(XOR(_a_, _b_), _b_) = _a_. This property is used extensively in symmetric-key cryptography.
====

Because only Alice and Dina have the ++rho++ key (derived from Alice and Dina's shared secret), only they can do this. Effectively, this encrypts the onion payload for Dina's eyes only.

Finally, Alice calculates a hash-based message authentication code (HMAC) for Dina's payload, which uses the ++mu++ key as its initialization key. This is shown in <<dina_hop_payload_hmac>>. 

[[dina_hop_payload_hmac]]
.Adding an HMAC integrity checksum to Dina's hop payload
image::images/mtln_1019.png[]

===== Onion routing replay protection and detection

((("onion routing","replay protection/detection")))The HMAC acts as a secure checksum and helps Dina verify the integrity of the hop payload. The 32-byte HMAC is appended to Dina's hop payload.
((("encrypt-then-mac")))Note that we compute the HMAC over the _encrypted_ data rather then over the plain-text data.
This is known as _encrypt-then-mac_ and is the recommended way to use a MAC, as it provides both plain-text _and_ ciphertext integrity.

((("AD (associated data)")))((("associated data (AD)")))Modern authenticated encryption also allows for the use of an optional set of plaintext bytes to also be authenticated, known as _associated data._
In practice, this is usually something like a plain-text packet header or other auxiliary information.
By including this associated data in the payload to be authenticated (MAC'ed), the verifier of the MAC ensures that this associated data hasn't been tampered with (e.g., swapping out the plain-text header on an encrypted packet).

In the context of the Lightning Network, this associated data is used to _strengthen_ the replay protection of this scheme.
As we'll learn in the following, replay protection ensures that an attacker can't _retransmit_ (replay) a packet into the network and observe its resulting path.
Instead, intermediate nodes are able to use the defined replay protection measures to detect and reject a replayed packet.
The base Sphinx packet format uses a log of all the ephemeral secret keys used to detect replays.
If a secret key is ever used again, then the node can detect it and reject the packet.

The nature of HTLCs in the Lightning Network allows us to further strengthen the replay protection by adding an additional _economic_ incentive.
Remember that the payment hash of an HTLC can only ever safely be used (for a complete payment) once.
If a payment hash is used again and traverses a node that has already seen the payment secret for that hash, then they can simply pull the funds and collect the entire payment amount without forwarding!
We can use this fact to strengthen the replay protection by requiring that the _payment hash_ is included in our HMAC computation as the associated data.
With this added step, attempting to replay an onion packet also requires the sender to commit to using the _same_ payment hash.
As a result, on top of the normal replay protection, an attacker also stands to lose the entire amount of the HTLC replayed.

One consideration with the ever-increasing set of session keys stored for replay protection is: are nodes able to reclaim this space?
In the context of the Lightning Network, the answer is: yes!
Once again, due to the unique attributes of the HTLC construct, we can make a further improvement over the base Sphinx protocol.
Given that HTLCs are _time-locked_ contracts based on the absolute block height, once an HTLC has expired, then the contract is effectively permanently closed.
As a result, nodes can use this CLTV (CHECKLOCKTIMEVERIFY operator) expiration height as an indicator to know when it's safe to garbage collect an entry in the anti-replay log.

==== Wrapping Chan's Hop Payload

In <<chan_onion_wrapping>> we see the steps used to wrap Chan's hop payload in the onion. These are the same steps Alice used to wrap Dina's hop payload.

[[chan_onion_wrapping]]
.Wrapping the onion for Chan
image::images/mtln_1020.png[]

Alice starts with the 1,300 onion payload created for Dina. The first 65 (or fewer) bytes of this are Dina's payload obfuscated and the rest is filler. Alice must be careful not to overwrite Dina's payload.

Next, Alice needs to locate the ephemeral public key (which was generated at the very start for each hop) that will be prepended to the routing packet at this hop.

Remember that rather than include a unique ephemeral public key (that the sender and intermediate node use in an ECDH operation to generate a shared secret), Sphinx uses a single ephemeral public key that is deterministically randomized at each hop.

When processing the packet, Dina will use her shared secret and public key to derive the blinding value (`b_dina`) and use that to re-randomize the ephemeral public key, in an identical operation to what Alice performs during initial packet construction.

Alice adds an inner HMAC checksum to Chan's payload and inserts it at the "front" (left side) of the onion payload, shifting the existing payload to the right by an equal amount.
Remember that there are effectively _two_ HMACs used in the scheme: the outer HMAC and the inner HMAC.
In this case, Chan's _inner_ HMAC is actually Dina's _outer_ HMAC.

Now Chan's payload is in the front of the onion. When Chan sees this, he has no idea how many payloads came before or after. It looks like the first of 20 hops always!

Next, Alice obfuscates the entire payload by XOR with the byte stream generated from the Alice-Chan ++rho++ key. Only Alice and Chan have this ++rho++ key, and only they can produce the byte stream to obfuscate and de-obfuscate the onion.
Finally, as we did in the earlier step, we compute Chan's outer HMAC, which is what she'll use to verify the integrity of the encrypted onion packet.

==== Wrapping Bob's Hop Payload

In <<bob_onion_wrapping>> we see the steps used to wrap Bob's hop payload in the onion.

All right, by now this is easy!

Start with the onion payload (obfuscated) containing Chan's and Dina's hop payloads.

Obtain the session key for this hop dervied from the blinding factor generated by the prior hop.
Include the prior hop's outer HMAC as this hop's inner HMAC.
Insert Bob's hop payload at the beginning and shift everything else over to the right, dropping a Bob-hop-payload-size chunk from the end (it was filler anyway).

Obfuscate the whole thing XOR with the ++rho++ key from the Alice-Bob shared secret so that only Bob can unwrap this.

Calculate the outer HMAC and stick it on the end of Bob's hop payload.(((range="endofrange", startref="ix_10_onion_routing-asciidoc12")))

[[bob_onion_wrapping]]
.Wrapping the onion for Bob
image::images/mtln_1021.png[]


==== The Final Onion Packet

((("onion routing","final onion packet")))The final onion payload is ready to be sent to Bob. Alice doesn't need to add any more hop payloads.

Alice calculates an HMAC for the onion payload to cryptographically secure it with a checksum that Bob can verify.

Alice adds a 33-byte public session key that will be used by each hop to generate a shared secret and the ++rho++, ++mu++, and ++pad++ keys.

Finally Alice puts the onion version number (+0+ currently) in the front. This allows for future upgrades of the onion packet format.

The result can be seen in <<onion_packet_2>>. (((range="endofrange", startref="ix_10_onion_routing-asciidoc11")))

[[onion_packet_2]]
.The onion packet
image::images/mtln_1015.png[]

=== Sending the Onion

((("onion routing","sending the onion", id="ix_10_onion_routing-asciidoc13", range="startofrange")))In this section we will look at how the onion packet is forwarded and how HTLCs are deployed along the path.

==== The update_add_htlc Message

((("onion routing","update_add_htlc message")))((("update_add_htlc message")))Onion packets are sent as part of the +update_add_htlc+ message. If you recall from <<update_add_htlc>>, in <<channel_operation>>, we saw the contents of the +update_add_htlc+ message are as follows:

----
[channel_id:channel_id]
[u64:id]
[u64:amount_msat]
[sha256:payment_hash]
[u32:cltv_expiry]
[1366*byte:onion_routing_packet]
----

You will recall that this message is sent by one channel partner to ask the other channel partner to add an HTLC. This is how Alice will ask Bob to add an HTLC to pay Dina. Now you understand the purpose of the last field, +onion_routing_packet+, which is 1,366 bytes long. It's the fully wrapped onion packet we just constructed!

==== Alice Sends the Onion to Bob

Alice will send the +update_add_htlc+ message to Bob. Let's look at what this message will contain:

+channel_id+:: This field contains the Alice-Bob channel ID, which in our example is +0000031e192ca1+ (see <<alice_dina_path_detail>>).

+id+:: The ID of this HTLC in this channel, starting at +0+.

+amount_msat+:: The amount of the HTLC: 50,200,000 millisatoshis.

+payment_hash+:: The RIPEMD160(SHA-256) payment hash:
+
+9e017f6767971ed7cea17f98528d5f5c0ccb2c71+.

+cltv_expiry+:: The expiry timelock for the HTLC will be 700,058. Alice adds 20 blocks to the expiry set in Bob's payload according to Bob's negotiated +cltv_expiry_delta+.

+onion_routing_packet+:: The final onion packet Alice constructed with all the hop payloads!

==== Bob Checks the Onion

As we saw in <<channel_operation>>, Bob will add the HTLC to the commitment transactions and update the state of the channel with Alice.

Bob will unwrap the onion he received from Alice as follows:

1. Bob takes the session key from the onion packet and derives the Alice-Bob shared secret.

2. Bob generates the ++mu++ key from the shared secret and uses it to verify the onion packet HMAC checksum.

Now that Bob has generated the shared key and verified the HMAC, he can start unwrapping the 1,300 byte onion payload inside the onion packet. The goal is for Bob to retrieve his own hop payload and then forward the remaining onion to the next hop.

If Bob extracts and removes his hop payload, the remaining onion will not be 1,300 bytes, it will be shorter! So the next hop will know that they are not the first hop and will be able to detect how long the path is. To prevent this, Bob needs to add more filler to refill the onion.

==== Bob Generates Filler

Bob generates filler in a slightly different way than Alice, but following the same general principle.

First, Bob _extends_ the onion payload by 1,300 bytes and fills them with +0+ values. Now the onion packet is 2,600 bytes long, with the first half containing the data Alice sent and the next half containing zeroes. This operation is shown in <<bob_extends>>. 

[[bob_extends]]
.Bob extends the onion payload by 1,300 (zero-filled) bytes
image::images/mtln_1023.png["Bob extends the onion payload by 1,300 (zero-filled) bytes"]

This empty space will become obfuscated and turn into "filler" by the same process that Bob uses to de-obfuscate his own hop payload. Let's see how that works.

[[bobDeobfuscates]]
==== Bob De-Obfuscates His Hop Payload

Next, Bob will generate the ++rho++ key from the Alice-Bob shared key. He will use this to generate a 2,600 byte stream, using the ChaCha20 algorithm.

[TIP]
====
The first 1,300 bytes of the byte stream generated by Bob are exactly the same as those generated by Alice using the ++rho++ key.
====

Next, Bob applies the 2,600 bytes of the ++rho++ byte stream to the 2,600-byte onion payload with a bitwise XOR operation.

The first 1,300 bytes will become de-obfuscated by this XOR operation, because it is the same operation Alice applied and XOR is involutory. So Bob will _reveal_ his hop payload followed by some data that seems scrambled.

At the same time, applying the ++rho++ byte stream to the 1,300 zeroes that were added to the onion payload will turn them into seemingly random filler data. This operation is shown in <<bob_deobfuscates>>.

[[bob_deobfuscates]]
.Bob de-obfuscates the onion, obfuscates the filler
image::images/mtln_1024.png["Bob de-obfuscates the onion, obfuscates the filler"]

==== Bob Extracts the Outer HMAC for the Next Hop

Remember that an inner HMAC is included for each hop, which will then become the outer HMAC for the _next_ hop.
In this case, Bob extracts the inner HMAC (he's already verified the integrity of the encrypted packet with the outer HMAC), and puts it aside because he'll append it to the de-obfuscated packet to allow Chan to verify the HMAC of his encrypted packet.

==== Bob Removes His Payload and Left-Shifts the Onion

Now Bob can remove his hop payload from the front of the onion and left-shift the remaining data. An amount of data equal to Bob's hop payload from the second-half 1,300 bytes of filler will now shift into the onion payload space. This is shown in <<bob_removes_shifts>>. 

Now Bob can keep the first half 1,300 bytes, and discard the extended (filler) 1,300 bytes.

Bob now has a 1,300-byte onion packet to send to the next hop. It is almost identical to the onion payload that Alice had created for Chan, except that the last 65 or so bytes of filler was put there by Bob and will be different.

[[bob_removes_shifts]]
.Bob removes the hop payload and left-shifts the rest, filling the gap with new filler
image::images/mtln_1025.png["Bob removes the hop payload and left-shifts the rest, filling the gap with new filler"]

[role="pagebreak-before"]
No one can tell the difference between filler put there by Alice and filler put there by Bob. Filler is filler! It's all random bytes anyway. Note that if Bob (or one of Bob's other aliases) is present in the route in two distinct locations, then they can tell the difference because the base protocol always uses the same payment hash across the entire route. Atomic multipath payments (AMPs) and Point Time-Locked Contracts (PTLCs) eliminate the correlation vector by randomizing the payment identifier across each route/hop.

==== Bob Constructs the New Onion Packet

Bob now copies the onion payload into the onion packet, appends the outer HMAC for chan, re-randomizes the session key (the same way Alice the sender does) with the elliptic curve multiplication operation, and appends a fresh version byte.

To re-randomize the session key, Bob first computes the blinding factor for his hop, using his node public key and the shared secret he derived:
```
b_bob = SHA-256(P_bob || shared_secret_bob)
```

With this generated, Bob now re-randomizes the session key by performing an EC multiplication using his session key and the blinding factor:
```
session_key_chan = session_key_bob * b_bob
```

The `session_key_chan` public key will then be appended to the front of the onion packet for processing by Chan.

==== Bob Verifies the HTLC Details

Bob's hop payload contains the instructions needed to create an HTLC for Chan.

In the hop payload, Bob finds a +short_channel_id+, +amt_to_forward+, and +cltv_expiry+.

First, Bob checks to see if he has a channel with that short ID. He finds that he has such a channel with Chan.

Next, Bob confirms that the outgoing amount (50,100 satoshis) is less than the incoming amount (50,200 satoshis), and therefore Bob's fee expectations are met.

Similarly, Bob checks that the outgoing +cltv_expiry+ is less than the incoming +cltv_expiry+, giving Bob enough time to claim the incoming HTLC if there is a breach.

==== Bob Sends the update_add_htlc to Chan

Bob now constructs and HTLC to send to Chan, as follows:

+channel_id+:: This field contains the Bob-Chan channel ID, which in our example is +000004040a61f0+ (see <<alice_dina_path_detail>>).

+id+:: The ID of this HTLC in this channel, starting at +0+.

+amount_msat+:: The amount of the HTLC: 50,100,000 millisatoshis.

+payment_hash+:: The RIPEMD160(SHA-256) payment hash:
+
+9e017f6767971ed7cea17f98528d5f5c0&#x200b;ccb2c71+. 
+
This is the same as the payment hash from Alice's HTLC.

+cltv_expiry+:: The expiry timelock for the HTLC will be 700,038.

+onion_routing_packet+:: The onion packet Bob reconstructed after removing his hop payload.

==== Chan Forwards the Onion

Chan repeats the exact same process as Bob:

1. Chan receives the +update_add_htlc+ and processes the HTLC request, adding it to commitment transactions.

2. Chan generates the Alice-Chan shared key and the ++mu++ subkey.

3. Chan verifies the onion packet HMAC, then extracts the 1,300-byte onion pass:[<span class="keep-together">payload</span>].

4. Chan extends the onion payload by 1,300 extra bytes, filling it with zeroes.

5. Chan uses the ++rho++ key to produce 2,600 bytes.

6. Chan uses the generated byte stream to XOR and de-obfuscate the onion payload. Simultaneously, the XOR operation obfuscates the extra 1,300 zeroes, turning them into filler. 

7. Chan extracts the inner HMAC in the payload, which will become the outer HMAC for Dina.

8. Chan removes his hop payload and left-shifts the onion payload by the same amount. Some of the filler generated in the 1,300 extended bytes moves into the first-half 1,300 bytes, becoming part of the onion payload.

9. Chan constructs the onion packet for Dina with this onion payload.

10. Chan builds an +update_add_htlc+ message for Dina and inserts the onion packet into it.

11. Chan sends the +update_add_htlc+ to Dina.

12. Chan re-randomizes the session key as Bob did in the prior hop for Dina.

==== Dina Receives the Final Payload

When Dina receives the +update_add_htlc+ message from Chan, she knows from the +payment_hash+ that this is a payment for her. She knows she is the last hop in the onion.

Dina follows the exact same process as Bob and Chan to verify and unwrap the onion, except she doesn't construct new filler and doesn't forward anything. Instead, Dina responds to Chan with +update_fulfill_htlc+ to redeem the HTLC. The +update_fulfill_htlc+ will flow backward along the path until it reaches Alice. All the HTLCs are redeemed and channel balances are updated. The payment is complete!(((range="endofrange", startref="ix_10_onion_routing-asciidoc13")))

=== Returning Errors

((("error return","onion routing and", id="ix_10_onion_routing-asciidoc14", range="startofrange")))((("onion routing","returning errors", id="ix_10_onion_routing-asciidoc15", range="startofrange")))This far we've looked at the forward propagation of the onion establishing the HTLCs and the backward propagation of the payment secret unwinding the HTLCs once payment is successful.

There is another very important function of onion routing: _error return_. If there is a problem with the payment, onion, or hops, we must propagate an error backwards to inform all nodes of the failure and unwind any HTLCs.

Errors generally fall into three categories: onion failures, node failures, and channel failures. These furthermore may be subdivided into permanent and transient errors. Finally, some errors contain channel updates to help with future payment delivery attempts.

[NOTE]
====
Unlike messages in the peer-to-peer (P2P) protocol (defined in https://github.com/lightningnetwork/lightning-rfc/blob/master/02-peer-protocol.md[BOLT #2: Peer Protocol for Channel Management]), errors are not sent as P2P messages but are wrapped inside onion return packets and follow the reverse of the onion path (back-propagating).
====

Error return is defined in https://github.com/lightningnetwork/lightning-rfc/blob/master/04-onion-routing.md#returning-errors[BOLT #4: Onion Routing, Returning Errors].

Errors are encoded by the returning node (the one that discovered an error) in a _return packet_ as follows:

----
    [32*byte:hmac]
    [u16:failure_len]
    [failure_len*byte:failuremsg]
    [u16:pad_len]
    [pad_len*byte:pad]
----

The return packet HMAC verification checksum is calculated with the ++um++ key, generated from the shared secret established by the onion.

[TIP]
====
The ++um++ key name is the reverse of the ++mu++ name, indicating the same use but in the opposite direction (back-propagation). 
====

Next, the returning node generates an +ammag+ (inverse of the word "gamma") key and obfuscates the return packet using an XOR operation with a byte stream generated from +ammag+.

Finally the return node sends the return packet to the hop from which it received the original onion.

Each hop receiving an error will generate an +ammag+ key and obfuscate the return packet again using an XOR operation with the byte stream from +ammag+.

Eventually, the sender (origin node) receives a return packet. It will then generate +ammag+ and ++um++ keys for each hop and XOR de-obfuscate the return error iteratively until it reveals the return packet.

[[failure_messages]]
==== Failure Messages

((("error return","failure messages", id="ix_10_onion_routing-asciidoc16", range="startofrange")))((("failure messages, onion routing and", id="ix_10_onion_routing-asciidoc17", range="startofrange")))The +failuremsg+ is defined in https://github.com/lightningnetwork/lightning-rfc/blob/master/04-onion-routing.md#failure-messages[BOLT #4: Onion Routing, Failure Messages].

A failure message consists of a two-byte +failure code+ followed by the data applicable to that failure type.

The top byte of the +failure_code+ is a set of binary flags that can be combined (with binary OR):


0x8000 (`BADONION`):: Unparsable onion encrypted by sending peer
0x4000 (`PERM`):: Permanent failure (otherwise transient)
0x2000 (`NODE`):: Node failure (otherwise channel)
0x1000 (`UPDATE`):: New channel update enclosed


The failure types shown in <<failure_types_table>> are currently defined.

include::failure_types_table.asciidoc[]

[[stuck_payments]]
===== Stuck payments

((("onion routing","stuck payments")))((("stuck payments")))In the current implementation of the Lightning Network, there is a possibility that a payment attempt becomes _stuck_: neither fulfilled nor cancelled by an error. This can happen due to a bug on an intermediary node, a node going offline while handling HTLCs, or a malicious node holding HTLCs without reporting an error. In all of these cases, the HTLC cannot be resolved until it expires. The timelock (CLTV) that is set on every HTLC helps resolve this condition (among other possible HTLC routing and channel failures).

However, this means that the sender of the HTLC has to wait until expiry, and the funds committed to that HTLC remain unavailable until the HTLC expires. Furthermore, the sender _cannot retry_ that same payment, because if they do, they run the risk of _both_ the original and the retried payment succeeding—the recipient gets paid twice. This is because, once sent, an HTLC cannot be "cancelled" by the sender—it either has to fail or expire. Stuck payments, while rare, create an unwanted user experience, where the user's wallet cannot pay or cancel a payment.

((("Point Time-Locked Contract (PTLC)")))((("PTLC (Point Time-Locked Contract)")))((("stuckless payments")))One proposed solution to this problem is called _stuckless payments_, and it depends on Point Time-Locked Contracts (PTLCs), which are payment contracts that use a different cryptographic primitive than HTLCs (i.e., point addition on the elliptic curve instead of a hash and secret preimage). PTLCs are cumbersome using ECDSA but much easier with Bitcoin's Taproot and Schnorr signature features, which were recently locked in for activation in November 2021. It is expected that PTLCs will be implemented in the Lightning Network after these Bitcoin features become activated(((range="endofrange", startref="ix_10_onion_routing-asciidoc17")))(((range="endofrange", startref="ix_10_onion_routing-asciidoc16"))).(((range="endofrange", startref="ix_10_onion_routing-asciidoc15")))(((range="endofrange", startref="ix_10_onion_routing-asciidoc14")))

[[keysend]]
=== Keysend Spontaneous Payments

((("keysend spontaneous payments")))((("onion routing","keysend spontaneous payments")))In the payment flow described earlier in the chapter, we assumed that Dina
received an invoice from Alice "out of band," or obtained it via some mechanism
unrelated to the protocol (typically copy/paste or QR code scans). This trait
means that the payment process always takes two steps: first, the sender
obtains an invoice, and second, uses the payment hash (encoded in the invoice) to
successfully route an HTLC. The extra round trip required to obtain an invoice
before making a payment may be a bottleneck in applications that involve
streaming micropayments over Lightning. What if we could just "push" a payment
over spontaneously, without having to obtain an invoice from the recipient
first? The `keysend` protocol is an end-to-end extension (only the sender and
receiver are aware) to the Lightning protocol that enables spontaneous push
payments.

==== Custom Onion TLV Records

((("onion routing","custom onion TLV records")))((("Type-Length-Value (TLV) format","custom onion TLV records")))The modern Lightning protocol uses the TLV (Type-Length-Value) encoding in
the onion to encode information that tells each node _where_ and _how_ to
forward the payment. Leveraging the TLV format, each piece of routing information
(like the next node to which to pass the HTLC) is assigned a specific type (or key)
encoded as a `BigSize` variable length integer (max sized as as 64-bit
integer). These "essential" (reversed values below `65536`) types are defined
in BOLT #4, along with the rest of the onion routing details. Onion types with a
value greater than `65536` are intended to be used by wallets and applications
as "custom records."

Custom records allow payment applications to attach additional metadata or
context to a payment as key/value pairs in the onion. Since the custom records
are included in the onion payload itself, like all other hop contents, the
records are end-to-end encrypted. As the custom records effectively consume a
portion of the fixed-size 1300-bytes onion packet, encoding each key and
value of each custom record reduces the amount of available space for encoding
the rest of the route. In practice, this means that the more onion space used for custom records, the shorter the route can be. Given that each HTLC
packet is fixed size, custom records don't _add_ any additional data to an
HTLC; rather, they reallocate bytes that would have been filled with random data
otherwise.

==== Sending and Receiving Keysend Payments

((("onion routing","sending/receiving keysend payments")))A `keysend` payment inverts the typical flow of an HTLC where the receiver
reveals a secret preimage to the sender. Instead, the sender includes the
preimage _within_ the onion to the receiver, and routes the HTLC to the
receiver. The receiver then decrypts the onion payload, and uses the included
preimage (which _must_ match the payment hash of the HTLC) to settle the
payment. As a result, `keysend` payments can be carried out without first
obtaining an invoice from the receiver, as the preimage is "pushed" over to
the receiver. A `keysend` payment uses a TLV custom record type of `5482373484`
to encode a 32-byte preimage value.

==== Keysend and Custom Records in Lightning Applications

((("onion routing","keysend and custom records in Lightning applications")))Many streaming Lightning applications use the `keysend` protocol to continually
stream satoshis to a destination identified by its public key in the network.
Typically, an application will also include metadata such as a
tipping/donation note or other application-level information in addition to
the `keysend` record.

=== Conclusion

The Lightning Network's onion routing protocol is adapted from the Sphinx protocol to better serve the needs of a payment network. As such, it offers a huge improvement in privacy and counter-surveillance compared to the public and transparent Bitcoin blockchain.(((range="endofrange", startref="ix_10_onion_routing-asciidoc0")))

In <<path_finding>> we will see how the combination of source routing and onion routing is used by Alice to find a good path and route the payment to Dina. To find a path, Alice first needs to learn about the network topology, which is the topic of <<gossip>>.
