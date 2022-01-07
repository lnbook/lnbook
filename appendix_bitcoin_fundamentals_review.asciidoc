[appendix]
[[bitcoin_fundamentals_review]]
== Bitcoin Fundamentals Review

((("Bitcoin (system)","fundamentals", id="ix_appendix-bitcoin-fundamentals-review-asciidoc0", range="startofrange")))The Lightning Network is capable of running above multiple blockchains, but is primarily anchored on Bitcoin. To understand the Lightning Network, you need a fundamental understanding of Bitcoin and its building blocks.

There are many good resources that you can use to learn more about Bitcoin, including the companion book _Mastering Bitcoin_, 2nd Edition, by Andreas M. Antonopoulos, which you can find on GitHub under https://github.com/bitcoinbook/bitcoinbook[an open source license]. However, you do not need to read a whole other book to be ready for this one!

In this chapter, we've collected the most important concepts you need to know about Bitcoin and explained them in the context of the Lightning Network. This way you can learn exactly what you need to know to grasp the Lightning Network without any distractions.

This chapter covers several important concepts from Bitcoin, including:

* Keys and digital signatures
* Hash functions
* Bitcoin transactions and their structure
* Bitcoin transaction chaining
* Transaction outpoints
* Bitcoin Script: locking and unlocking scripts
* Basic locking scripts
* Complex and conditional locking scripts
* Timelocks


=== Keys and Digital Signatures

((("Bitcoin (system)","keys and digital signatures", id="ix_appendix-bitcoin-fundamentals-review-asciidoc1", range="startofrange")))((("Bitcoin (system)","private keys", id="ix_appendix-bitcoin-fundamentals-review-asciidoc2", range="startofrange")))((("keys", id="ix_appendix-bitcoin-fundamentals-review-asciidoc3", range="startofrange")))((("private keys", id="ix_appendix-bitcoin-fundamentals-review-asciidoc4", range="startofrange")))You may have heard that bitcoin is based on _cryptography_, which is a branch of mathematics used extensively in computer security. Cryptography can also be used to prove knowledge of a secret without revealing that secret (digital signature), or prove the authenticity of data (digital fingerprint). These types of cryptographic proofs are the mathematical tools critical to Bitcoin and used extensively in Bitcoin applications.

Ownership of bitcoin is established through _digital keys_, _bitcoin addresses_, and _digital signatures_. The digital keys are not actually stored in the network, but are instead created and stored by users in a file, or simple database, called a _wallet_. The digital keys in a user's wallet are completely independent of the Bitcoin Protocol and can be generated and managed by the user's wallet software without reference to the blockchain or access to the internet.

Most Bitcoin transactions require a valid digital signature to be included in the blockchain, which can only be generated with a secret key; therefore, anyone with a copy of that key has control of the bitcoin.  The digital signature used to spend funds is also referred to as a _witness_, a term used in cryptography. The witness data in a bitcoin transaction testifies to the true ownership of the funds being spent. Keys come in pairs consisting of a private (secret) key and a public key. Think of the public key as similar to a bank account number and the private key as similar to the secret PIN.

==== Private and Public Keys

A private key is simply a number, picked at random. In practice, and to make managing many keys easy, most Bitcoin wallets generate a sequence of private keys from a single random _seed_ using a deterministic derivation algorithm. Simply put, a single random number is used to produce a repeatable sequence of seemingly random numbers that are used as private keys. This allows users to only back up the seed and be able to _derive_ all the keys they need from that seed.

((("elliptic curve")))Bitcoin, like many other cryptocurrencies and blockchains, uses _elliptic curves_ for security. In Bitcoin, elliptic curve multiplication on the _secp256k1_ elliptic curve is used as a ((("one-way function")))_one-way function_. Simply put, the nature of elliptic curve math makes it trivial to calculate the scalar multiplication of a point but impossible to calculate the inverse (division, or discrete logarithm).

((("Bitcoin (system)","public keys")))((("public keys")))Each private key has a corresponding _public key_, which is calculated from the private key, using scalar multiplication on the elliptic curve. In simple terms, with a private key _k_, we can multiply it with a constant _G_ to produce a public key _K_:

++++
<ul class="simplelist">
<li><em>K</em> = <em>k</em>*<em>G</em></li>
</ul>
++++

It is impossible to reverse this calculation. Given a public key _K_, one cannot calculate the private key _k_. Division by _G_ is not possible in elliptic curve math. Instead, one would have to try all possible values of _k_ in an exhaustive process called a _brute-force attack_. Because _k_ is a 256-bit number, exhausting all possible values with any classical computer would require more time and energy than available in this universe.

==== Hashes

((("Bitcoin (system)","hashes", id="ix_appendix-bitcoin-fundamentals-review-asciidoc5", range="startofrange")))((("cryptographic hash functions", id="ix_appendix-bitcoin-fundamentals-review-asciidoc6", range="startofrange")))((("hashes", id="ix_appendix-bitcoin-fundamentals-review-asciidoc7", range="startofrange")))Another important tool used extensively in Bitcoin, and in the Lightning Network, are _cryptographic hash functions_, and specifically the SHA-256 hash function.

((("digest function")))((("hash function, defined")))A hash function, also known as a _digest function_, is a function that takes arbitrary length data and transforms it into a fixed length result, called the _hash_, _digest_, or _fingerprint_ (see <<SHA256>>). Importantly, hash functions are _one-way_ functions, meaning that you can't reverse them and calculate the input data from the fingerprint.

[[SHA256]]
.The SHA-256 cryptographic hash algorithm
image::images/mtln_aa01.png["The SHA-256 cryptographic hash algorithm"]

[role="pagebreak-before"]
For example, if we use a command-line terminal to feed the text "Mastering the Lightning Network" into the SHA-256 function, it will produce a fingerprint as follows:

----
$ echo -n "Mastering the Lightning Network" | shasum -a 256

ce86e4cd423d80d054b387aca23c02f5fc53b14be4f8d3ef14c089422b2235de  -
----

[TIP]
====
The input used to calculate a hash is also called a _preimage_.
====

The length of the input can be much bigger, of course. Let's try the same thing with the https://bitcoin.org/bitcoin.pdf[PDF file of the Bitcoin whitepaper] from Satoshi Nakamoto:

----
$ wget http://bitcoin.org/bitcoin.pdf
$ cat bitcoin.pdf | shasum -a 256
b1674191a88ec5cdd733e4240a81803105dc412d6c6708d53ab94fc248f4f553  -
----

While it takes longer than a single sentence, the SHA-256 function processes the 9-page PDF, "digesting" it into a 256-bit fingerprint.

Now at this point you might be wondering how it is possible for a function that digests data of unlimited size to produce a unique fingerprint that is a fixed-size number?

In theory, since there is an infinite number of possible preimages (inputs) and only a finite number of fingerprints, there must be many preimages that produce the same 256-bit fingerprint. ((("collision")))When two preimages produce the same hash, this is known as a _collision_.

In practice, a 256-bit number is so large that you will never find a collision on purpose. Cryptographic hash functions work on the basis that a search for a collision is a brute-force effort that takes so much energy and time that it is not practically possible.

Cryptographic hash functions are broadly used in a variety of applications because they have some useful features. They are:

Deterministic:: The same input always produces the same hash.

Irreversible:: It is not possible to compute the preimage of a hash.

Collision-proof:: It is computationally infeasible to find two messages that have the same hash.

Uncorrelated:: A small change in the input produces such a big change in the output that the output seems uncorrelated to the input.

Uniform/random:: A cryptographic hash function produces hashes that are uniformly distributed across the entire 256-bit space of possible outputs. The output of a hash appears to be random, though it is not truly random.

Using these features of cryptographic hashes, we can build some interesting pass:[<span class="keep-together">applications</span>]:

Fingerprints:: A hash can be used to fingerprint a file or message so that it can be uniquely identified. Hashes can be used as universal identifiers of any data set.

Integrity proof:: A fingerprint of a file or message demonstrates its integrity because the file or message cannot be tampered with or modified in any way without changing the fingerprint. This is often used to ensure software has not been tampered with before installing it on your computer.

Commitment/nonrepudiation:: You can commit to a specific preimage (e.g., a number or message) without revealing it by publishing its hash. Later, you can reveal the secret, and everyone can verify that it is the same thing you committed to earlier because it produces the published hash.

Proof-of-work/hash grinding:: You can use a hash to prove you have done computational work by showing a nonrandom pattern in the hash which can only be produced by repeated guesses at a preimage. For example, the hash of a Bitcoin block header starts with a lot of zero bits. The only way to produce it is by changing a part of the header and hashing it trillions of times until it produces that pattern by chance.

Atomicity:: You can make a secret preimage a prerequisite of spending funds in several linked transactions. If any one of the parties reveals the preimage in order to spend one of the transactions, all the other parties can now spend their transactions too. All or none become spendable, achieving atomicity across several transactions.(((range="endofrange", startref="ix_appendix-bitcoin-fundamentals-review-asciidoc7")))(((range="endofrange", startref="ix_appendix-bitcoin-fundamentals-review-asciidoc6")))(((range="endofrange", startref="ix_appendix-bitcoin-fundamentals-review-asciidoc5")))

==== Digital Signatures

((("Bitcoin (system)","digital signatures")))((("digital signatures")))The private key is used to create signatures that are required to spend bitcoin by proving ownership of funds used in a transaction.

A _digital signature_ is a number that is calculated from the application of the private key to a specific message.

Given a message _m_ and a private key _k_, a signature function __F~sign~__ can produce a signature _S_:

[latexmath]
++++
$ S = F_{sign}(m, k) $
++++

This signature _S_ can be independently verified by anyone who has the public key _K_ (corresponding to private key _k_), and the message:

[latexmath]
++++
$ F_{verify}(m, K, S) $
++++

If __F~verify~__ returns a true result, then the verifier can confirm that the message _m_ was signed by someone who had access to the private key _k_. Importantly, the digital signature proves the possession of the private key _k_ at the time of signing, without revealing _k_.

Digital signatures use a cryptographic hash algorithm. The signature is applied to a hash of the message, so that the message _m_ is "summarized" to a fixed-length hash _H_(_m_) that serves as a fingerprint.

By applying the digital signature on the hash of a transaction, the signature not only proves the authorization, but also "locks" the transaction data, ensuring its integrity. A signed transaction cannot be modified because any change would result in a different hash and invalidate the signature.

==== Signature Types

((("signature hash type")))Signatures are not always applied to the entire transaction. To provide signing flexibility, a Bitcoin digital signature contains a prefix called the signature hash type, which specifies which part of the transaction data is included in the hash. This allows the signature to commit or "lock" all, or only some of, the data in the transaction. The most common signature hash type is +SIGHASH_ALL+ which locks everything in the transaction by including all the transaction data in the hash that is signed. By comparison, +SIGHASH_SINGLE+ locks all the transaction inputs, but only one output (more about inputs and outputs in the next section). Different signature hash types can be combined to produce six different "patterns" of transaction data that are locked by the signature.

More information about signature hash types can be found in https://github.com/bitcoinbook/bitcoinbook/blob/develop/ch06.asciidoc#sighash_types[the section "Signature Hash Types" in Chapter 6 of _Mastering Bitcoin_, Second Edition].(((range="endofrange", startref="ix_appendix-bitcoin-fundamentals-review-asciidoc4")))(((range="endofrange", startref="ix_appendix-bitcoin-fundamentals-review-asciidoc3")))(((range="endofrange", startref="ix_appendix-bitcoin-fundamentals-review-asciidoc2")))(((range="endofrange", startref="ix_appendix-bitcoin-fundamentals-review-asciidoc1")))

=== Bitcoin Transactions

((("Bitcoin (system)","transactions", id="ix_appendix-bitcoin-fundamentals-review-asciidoc8", range="startofrange")))((("Bitcoin transactions", id="ix_appendix-bitcoin-fundamentals-review-asciidoc9", range="startofrange")))_Transactions_ are data structures that encode the transfer of value between participants in the bitcoin system.

[[utxo]]
==== Inputs and Outputs

((("Bitcoin transactions","inputs and outputs", id="ix_appendix-bitcoin-fundamentals-review-asciidoc10", range="startofrange")))The fundamental building block of a bitcoin transaction is a transaction output. ((("transaction outputs")))_Transaction outputs_ are indivisible chunks of bitcoin currency, recorded on the blockchain, and recognized as valid by the entire network. A transaction spends inputs and creates outputs. ((("transaction inputs")))Transaction _inputs_ are simply references to outputs of previously recorded transactions. This way, each transaction spends the outputs of previous transactions and creates new outputs (see <<transaction_structure>>).

[[transaction_structure]]
.A transaction transfers value from inputs to outputs
image::images/mtln_aa02.png["transaction inputs and outputs"]

((("unspent transaction outputs (UTXOs)")))((("UTXOs (unspent transaction outputs)")))Bitcoin full nodes track all available and spendable outputs, known as _unspent transaction outputs_ (UTXOs). The collection of all UTXOs is known as the UTXO set, which currently numbers in the millions of UTXOs. The UTXO set grows as new UTXOs are created and shrinks when UTXOs are consumed. Every transaction represents a change (state transition) in the UTXO set, by consuming one or more UTXOs as _transaction inputs_ and creating one or more UTXOs as its _transaction outputs_.

For example, let's assume that a user Alice has a 100,000 satoshi UTXO that she can spend. Alice can pay Bob 100,000 satoshi by constructing a transaction with one input (consuming her existing 100,000 satoshi input) and one output that "pays" Bob 100,000 satoshi. Now Bob has a 100,000 satoshi UTXO that he can spend, creating a new transaction that consumes this new UTXO and spends it to another UTXO as a payment to another user, and so on (see <<alice_100ksat_to_bob>>).

[[alice_100ksat_to_bob]]
.Alice pays 100,000 satoshis to Bob
image::images/mtln_aa03.png["Alice pays 100,000 satoshis to Bob"]

A transaction output can have an arbitrary (integer) value denominated in satoshis. Just as dollars can be divided down to two decimal places as cents, bitcoin can be divided down to eight decimal places as satoshis. Although an output can have any arbitrary value, once created it is indivisible. This is an important characteristic of outputs that needs to be emphasized: outputs are discrete and indivisible units of value, denominated in integer satoshis. An unspent output can only be consumed in its entirety by a transaction.

So what if Alice wants to pay Bob 50,000 satoshi, but only has an indivisible 100,000 satoshi UTXO? Alice will need to create a transaction that consumes (as its input) the 100,000 satoshi UTXO and has two outputs: one paying 50,000 satoshi to Bob and one paying 50,000 satoshi _back_ to Alice as "change" (see <<alice_50ksat_to_bob_change>>).

[[alice_50ksat_to_bob_change]]
.Alice pays 50k sat to Bob and 50k sat to herself as change
image::images/mtln_aa04.png["Alice pays 50,000 satoshis to Bob and 50,000 satoshis to herself as change"]

[TIP]
====
There's nothing special about a change output or any way to distinguish it from any other output. It doesn't have to be the last output. There could be more than one change output, or no change outputs. Only the creator of the transaction knows which outputs are to others and which outputs are to addresses they own and therefore "change."
====

Similarly, if Alice wants to pay Bob 85,000 satoshi but has two 50,000 satoshi UTXOs available, she has to create a transaction with two inputs (consuming both her 50,000 satoshi UTXOs) and two outputs, paying Bob 85,000 and sending 15,000 satoshi back to herself as change (see <<tx_twoin_twoout>>).

[[tx_twoin_twoout]]
.Alice uses two 50k inputs to pay 85k sat to Bob and 15k sat to herself as change
image::images/mtln_aa05.png["Alice uses two 50k inputs to pay 85k sat to Bob and 15k sat to herself as change"]

The preceding illustrations and examples show how a Bitcoin transaction combines (spends) one or more inputs and creates one or more outputs. A transaction can have hundreds or even thousands of inputs and outputs.

[TIP]
====
While the transactions created by the Lightning Network have multiple outputs, they do not have "change" per se, because the entire available balance of a channel is split between the two channel partners.(((range="endofrange", startref="ix_appendix-bitcoin-fundamentals-review-asciidoc10")))
====

==== Transaction Chains

((("Bitcoin transactions","transaction chains")))((("transaction chains")))Every output can be spent as an input in a subsequent transaction. So, for example, if Bob decided to spend 10,000 satoshi in a transaction paying Chan, and Chan spent 4,000 satoshi to pay Dina, it would play out as shown in <<tx_chain>>.

An output is considered _spent_ if it is referenced as an input in another transaction that is recorded on the blockchain. An output is considered _unspent_ (and available for spending) if no recorded transaction references it.

The only type of transaction that doesn't have inputs is a special transaction created by Bitcoin miners called the _coinbase transaction_. The coinbase transaction has only outputs and no inputs because it creates new bitcoin from mining. Every other transaction spends one or more previously recorded outputs as its inputs.

Since transactions are chained, if you pick a transaction at random, you can follow any one of its inputs backward to the previous transaction that created it. If you keep doing that, you will eventually reach a coinbase transaction where the bitcoin was first mined.

[[tx_chain]]
.Alice pays Bob who pays Chan who pays Dina
image::images/mtln_aa06.png["Alice pays Bob who pays Chan who pays Dina"]


==== TxID: Transaction Identifiers

((("Bitcoin transactions","transaction identifiers")))((("TxID (transaction identifiers)")))Every transaction in the Bitcoin system is identified by a unique identifier (assuming the existence of BIP-0030), called the _transaction ID_ or _TxID_ for short. To produce a unique identifier, we use the SHA-256 cryptographic hash function to produce a hash of the transaction's data. This "fingerprint" serves as a universal identifier. A transaction can be referenced by its transaction ID, and once a transaction is recorded on the Bitcoin blockchain, every node in the Bitcoin network knows that this transaction is valid.

For example, a transaction ID might look like this:

.A transaction ID produced from hashing the transaction data
----
e31e4e214c3f436937c74b8663b3ca58f7ad5b3fce7783eb84fd9a5ee5b9a54c
----

This is a real transaction (created as an example for the _Mastering Bitcoin_ book) that can be found on the Bitcoin blockchain. Try to find it by entering this TxID into a block explorer:

++++
<ul class="simplelist">
<li><a href="https://blockstream.info/tx/e31e4e214c3f436937c74b8663b3ca58f7ad5b3fce7783eb84fd9a5ee5b9a54c"><em>https://blockstream.info/tx/e31e4e214c3f436937c74b8663b3ca58f7ad5b3fce7783eb84fd9a5ee5b9a54c</em></a></li></ul>
++++

or use the short link (case-sensitive):

++++
<ul class="simplelist">
<li><a href="http://bit.ly/AliceTx"><em>http://bit.ly/AliceTx</em></a></li>
</ul>
++++

==== Outpoints: Output Identifiers

((("Bitcoin transactions","outpoints (output identifiers)")))((("outpoints (output identifiers)")))Because every transaction has a unique ID, we can also identify a transaction output within that transaction uniquely by reference to the TxID and the output index number. The first output in a transaction is output index 0, the second output is output index 1, and so on. An output identifier is commonly known as an _outpoint_.

By convention we write an outpoint as the TxID, a colon, and the output index number:

.A outpoint: identifying an output by TxID and index number
----
7957a35fe64f80d234d76d83a2a8f1a0d8149a41d81de548f0a65a8a999f6f18:0
----

Output identifiers (outpoints) are the mechanisms that link transactions together in a chain. Every transaction input is a reference to a specific output of a previous transaction. That reference is an outpoint: a TxID and output index number. So a transaction "spends" a specific output (by index number) from a specific transaction (by TxID) to create new outputs that themselves can be spent by reference to the outpoint.

<<tx_chain_vout>> presents the chain of transactions from Alice to Bob to Chan to Dina, this time with outpoints in each of the inputs.

[[tx_chain_vout]]
.Transaction inputs refer to outpoints forming a chain
image::images/mtln_aa07.png["Transaction inputs refer to outpoints forming a chain"]

The input in Bob's transaction references Alice's transaction (by TxID) and the 0 indexed output.

The input in Chan's transaction references Bob's transaction's TxID and the first indexed output, because the payment to Chan is output #1. In Bob's payment to Chan, Bob's change is output #0.footnote:[Recall that change doesn't have to be the last output in a transaction and is in fact indistinguishable from other outputs.]

Now, if we look at Alice's payment to Bob, we can see that Alice is spending an outpoint that was the third (output index #2) output in a transaction whose ID is 6a5f1b3[...]. We don't see that referenced transaction in the diagram, but we can deduce these details from the outpoint.(((range="endofrange", startref="ix_appendix-bitcoin-fundamentals-review-asciidoc9")))(((range="endofrange", startref="ix_appendix-bitcoin-fundamentals-review-asciidoc8")))

=== Bitcoin Script

((("Bitcoin (system)","script", id="ix_appendix-bitcoin-fundamentals-review-asciidoc11", range="startofrange")))((("Bitcoin script", id="ix_appendix-bitcoin-fundamentals-review-asciidoc12", range="startofrange")))The final element of Bitcoin that is needed to complete our understanding is the scripting language that controls access to outpoints. So far, we've simplified the description by saying "Alice signs the transaction to pay Bob." Behind the scenes, however, there is some hidden complexity that makes it possible to implement more complex spending conditions. The simplest and most common spending condition is "present a signature matching the following public key." A spending condition like this is recorded in each output as _locking script_ written in a scripting language called _Bitcoin Script_.

Bitcoin Script is an extremely simple stack-based scripting language. It does not contain loops or recursion and therefore is _Turing incomplete_ (meaning it cannot express arbitrary complexity and has predictable execution). Those familiar with the (now ancient) programming language FORTH will recognize the syntax and style.

==== Running Bitcoin Script

((("Bitcoin script","running")))In simple terms, the Bitcoin system evaluates Bitcoin Script by running the script on a stack; if the final result is +TRUE+, it considers the spending condition satisfied and the transaction valid.

Let's look at a very simple example of Bitcoin Script, which adds the numbers 2 and 3 and then compares the result to the number 5:

----
2 3 ADD 5 EQUAL
----

In <<figa08>>, we see how this script is executed (from left to right).

[[figa08]]
.Example of Bitcoin Script execution
image::images/mtln_aa08.png["Example of Bitcoin Script execution"]

[role="pagebreak-before less_space"]
==== Locking and Unlocking Scripts

((("Bitcoin script","locking/unlocking")))Bitcoin Script is made up of two parts:

Locking scripts:: ((("locking scripts")))These are embedded in transaction outputs, setting the conditions that must be fulfilled to spend that output. For example, Alice's wallet adds a locking script to the output paying Bob, that sets the condition that Bob's signature is required to spend it.

Unlocking scripts:: ((("unlocking scripts")))These are embedded in transaction inputs, fulfilling the conditions set by the referenced output's locking script. For example, Bob can unlock the preceding output by providing an unlocking script containing a digital signature.

Using a simplified model, for validation, the unlocking script and locking script are concatenated and executed (P2SH and SegWit are exceptions). For example, if someone locked a transaction output with the locking script +"3 ADD 5 EQUAL"+, we could spend it with the unlocking script "+2+" in a transaction input. Anyone validating that transaction would concatenate our unlocking script (+2+) and the locking script (+3 ADD 5 EQUAL+) and run the result through the Bitcoin Script execution engine. They would get +TRUE+ and we would be able to spend the output.

Obviously, this simplified example would make a very poor choice for locking an actual Bitcoin output because there is no secret, just basic arithmetic. Anyone could spend the output by providing the answer "2." Most locking scripts therefore require demonstrating knowledge of a secret.

==== Locking to a Public Key (Signature)

((("Bitcoin script","locking to a public key (signature)")))((("locking scripts","locking to a public key (signature)")))((("signatures, locking to a public key")))The simplest form of a locking script is one that requires a signature. Let's consider Alice's transaction that pays Bob 50,000 satoshis. The output Alice creates to pay Bob will have a locking script requiring Bob's signature and would look like this:

[[bob_locking_script]]
.A locking script that requires a digital signature from Bob's private key
----
<Bob Public Key> CHECKSIG
----

The operator `CHECKSIG` takes two items from the stack: a signature and a public key. As you can see, Bob's public key is in the locking script, so what is missing is the signature corresponding to that public key. This locking script can only be spent by Bob, because only Bob has the corresponding private key needed to produce a digital signature matching the public key.

To unlock this locking script, Bob would provide an unlocking script containing only his digital signature:

[[bob_unlocking_script]]
.An unlocking script containing (only) a digital signature from Bob's private key
----
<Bob Signature>
----

In <<locking_unlocking_chain>> you can see the locking script in Alice's transaction (in the output that pays Bob) and the unlocking script (in the input that spends that output) in Bob's transaction.

[[locking_unlocking_chain]]
.A transaction chain showing the locking script (output) and unlocking script (input)
image::images/mtln_aa09.png["A transaction chain showing the locking script (output) and unlocking script (input)"]

To validate Bob's transaction, a Bitcoin node would do the following:

. Extract the unlocking script from the input (+<Bob Signature>+).
. Look up the outpoint it is attempting to spend (+a643e37...3213:0+). This is Alice's transaction and would be found on the blockchain.
. Extract the locking script from that outpoint (+<Bob PubKey> CHECKSIG+).
. Concatenate into one script, placing the unlocking script in front of the locking script (+<Bob Signature> <Bob PubKey> CHECKSIG+).
. Execute this script on the Bitcoin Script execution engine to see what result is produced.
. If the result is +TRUE+, deduce that Bob's transaction is valid because it was able to fulfill the spending condition to spend that outpoint.

==== Locking to a Hash (Secret)

((("hashlock")))((("locking scripts","locking to a hash (secret)")))Another type of locking script, one that is used in the Lightning Network, is a _hashlock_. To unlock it, you must know the secret _preimage_ to the hash.

To demonstrate this, let's have Bob generate a random number +R+ and keep it secret:

----
R = 1833462189
----

[role="pagebreak-before"]
Now, Bob calculates the SHA-256 hash of this number:

----
H = SHA256(R) =>
H = SHA256(1833462189) =>
H = 0ffd8bea4abdb0deafd6f2a8ad7941c13256a19248a7b0612407379e1460036a
----

Now, Bob gives the hash +H+ we calculated previously to Alice, but keeps the number +R+ secret. Recall that because of the properties of cryptographic hashes, Alice can't "reverse" the hash calculation and guess the number +R+.

Alice creates an output paying 50,000 satoshi with the locking script:

----
HASH256 H EQUAL
----

where +H+ is the actual hash value (+0ffd8...036a+) that Bob gave to Alice.

Let's explain this script:

The +HASH256+ operator pops a value from the stack and calculates the SHA-256 hash of that value. Then it pushes the result onto the stack.

The +H+ value is pushed onto the stack, and then the +EQUAL+ operator checks if the two values are the same and pushes +TRUE+ or +FALSE+ onto the stack accordingly.

Therefore, this locking script will only work if it is combined with an unlocking script that contains +R+, so that when concatenated, we have:

----
R HASH256 H EQUAL
----

Only Bob knows +R+, so only Bob can produce a transaction with an unlocking script revealing the secret value +R+.

Interestingly, Bob can give the +R+ value to anyone else, who can then spend that Bitcoin. This makes the secret value +R+ almost like a bitcoin "voucher," since anyone who has it can spend the output Alice created. We'll see how this is a useful property for the Lightning Network!

[[multisig]]
==== Multisignature Scripts

((("Bitcoin script","multisignature scripts")))((("multisignature scripts")))The Bitcoin Script language provides a multisignature building block (primitive), that can be used to build escrow services and complex ownership configurations between several stakeholders. ((("K-of-N scheme")))((("multisignature scheme")))An arrangement that requires multiple signatures to spend Bitcoin is called a _multisignature scheme_, further specified as a _K-of-N_ scheme, where:

* _N_ is the total number of signers identified in the multisignature scheme, and
* _K_ is the _quorum_ or _threshold_: the minimum number of signatures to authorize spending.

[role="pagebreak-before"]
The script for an __K__-of-__N__ multisignature is:

----
K <PubKey1> <PubKey2> ... <PubKeyN> N CHECKMULTISIG
----

where _N_ is the total number of listed public keys (Public Key 1 through Public Key _N_) and _K_ is the threshold of required signatures to spend the output.

The Lightning Network uses a 2-of-2 multisignature scheme to build a payment channel. For example, a payment channel between Alice and Bob would be built on a 2-of-2 multisignature like this:

----
2 <PubKey Alice> <PubKey Bob> 2 CHECKMULTISIG
----

The preceding locking script can be satisfied with an unlocking script containing a pair of signatures:footnote:[The first argument (0) does not have any meaning but is required due to a bug in Bitcoin's multisignature implementation. This issue is described in _Mastering Bitcoin_, https://github.com/bitcoinbook/bitcoinbook/blob/develop/ch07.asciidoc[Chapter 7].]

----
0 <Sig Alice> <Sig Bob>
----
The two scripts together would form the combined validation script:

----
0 <Sig Alice> <Sig Bob> 2 <PubKey Alice> <PubKey Bob> 2 CHECKMULTISIG
----

A multisignature locking script can be represented by a Bitcoin address, encoding the hash of the locking script. For example, the initial funding transaction of a Lightning payment channel is a transaction that pays to an address that encodes a locking script of a 2-of-2 multisig of the two channel partners.

==== Timelock Scripts

((("Bitcoin script","timelock scripts")))((("timelock scripts")))Another important building block that exists in Bitcoin and is used extensively in the Lightning Network is a _timelock_. A timelock is a restriction on spending that requires that a certain time or block height has elapsed before spending is allowed. It is a bit like a postdated check drawn from a bank account that can't be cashed before the date on the check.

Bitcoin has two levels of timelocks: transaction-level timelocks and output-level timelocks.

((("transaction-level timelock")))A _transaction-level timelock_ is recorded in the transaction `nLockTime` field of the transaction and prevents the entire transaction from being accepted before the timelock has passed. Transaction-level timelocks are the most commonly used timelock mechanism in Bitcoin today.

((("output-level timelock")))An _output-level timelock_ is created by a script operator. There are two types of output timelocks: absolute timelocks and relative timelocks.

((("absolute timelock")))Output-level _absolute timelocks_ are implemented by the operator +CHECKLOCKTIMEVERIFY+, which is often shortened in conversation as _CLTV_. Absolute timelocks implement a time constraint with an absolute timestamp or blockheight, expressing the equivalent of "not spendable before block 800,000."

((("relative timelock")))Output-level _relative timelocks_ are implemented by the operator +CHECKSEQUENCEVERIFY+, often shortened in conversation as _CSV_. Relative timelocks implement a spending constraint that is relative to the confirmation of the transaction, expressing the equivalent of "can't be spent until 1,024 blocks after confirmation."

[[conditional_scripts]]
==== Scripts with Multiple Conditions

((("Bitcoin script","scripts with multiple conditions")))((("conditional clauses")))One ((("flow control", id="ix_appendix-bitcoin-fundamentals-review-asciidoc13", range="startofrange")))of the more powerful features of Bitcoin Script is flow control, also known as conditional clauses. You are probably familiar with flow control in various programming languages that use the construct +IF...THEN...ELSE+. Bitcoin conditional clauses look a bit different, but are essentially the same construct.

At a basic level, bitcoin conditional opcodes allow us to construct a locking script that has two ways of being unlocked, depending on a +TRUE+/+FALSE+ outcome of evaluating a logical condition. For example, if x is +TRUE+, the locking script is A +ELSE+ the locking script is B.

Additionally, bitcoin conditional expressions can be _nested_ indefinitely, meaning that a conditional clause can contain another within it, which contains another, etc. Bitcoin Script flow control can be used to construct very complex scripts with hundreds or even thousands of possible execution paths. There is no limit to nesting, but consensus rules impose a limit on the maximum size, in bytes, of a script.

Bitcoin implements flow control using the +IF+, +ELSE+, +ENDIF+, and +NOTIF+ opcodes. Additionally, conditional expressions can contain boolean operators such as +BOOLAND+, pass:[<span class="keep-together"><code>BOOLOR</code></span>], and +NOT+.

At first glance, you may find Bitcoin's flow control scripts confusing. That is because Bitcoin Script is a stack language. The same way that the arithmetic operation latexmath:[$1 + 1$] looks "backward" when expressed in Bitcoin Script as +1 1 ADD+, flow control clauses in
Bitcoin also look "backward."

In most traditional (procedural) programming languages, flow control looks like this:

.Pseudocode of flow control in most programming languages
----
if (condition):
  code to run when condition is true
else:
  code to run when condition is false
code to run in either case
----

In a stack-based language like Bitcoin Script, the logical condition comes _before_ the +IF+, which makes it look "backward," like this:

.Bitcoin Script flow control
----
condition
IF
  code to run when condition is true
ELSE
  code to run when condition is false
ENDIF
code to run in either case
----

When reading Bitcoin Script, remember that the condition being evaluated comes _before_ the +IF+ opcode.

==== Using Flow Control in Scripts

((("Bitcoin script","using flow control in")))A very common use for flow control in Bitcoin Script is to construct a locking script that offers multiple execution paths, each a different way of redeeming the UTXO.

Let's look at a simple example, where we have two signers, Alice and Bob, and either one is able to redeem. With multisig, this would be expressed as a 1-of-2 multisig script. For the sake of demonstration, we will do the same thing with an +IF+ clause:

----
IF
 <Alice's Pubkey> CHECKSIG
ELSE
 <Bob's Pubkey> CHECKSIG
ENDIF
----

Looking at this locking script, you may be wondering: "Where is the condition? There is nothing preceding the +IF+ clause!"

The condition is not part of the locking script. Instead, the condition will be _offered in the unlocking script_, allowing Alice and Bob to "choose" which execution path they want.

Alice redeems this with the unlocking script:
----
<Alice's Sig> 1
----

The +1+ at the end serves as the condition (+TRUE+) that will make the +IF+ clause execute the first redemption path for which Alice has a signature.

For Bob to redeem this, he would have to choose the second execution path by giving a +FALSE+ value to the +IF+ clause:

----
<Bob's Sig> 0
----

Bob's unlocking script puts a +0+ on the stack, causing the +IF+ clause to execute the second (+ELSE+) script, which requires Bob's signature.

Because each of the two conditions also requires a signature, Alice can't use the second clause and Bob can't use the first clause; they don't have the necessary signatures for that!

Since conditional flows can be nested, so can the +TRUE+ / +FALSE+ values in the unlocking script, to navigate a complex path of conditions.

In <<htlc_script_example>> you can see an example of the kind of complex script that is used in the Lightning Network, with multiple conditions.footnote:[From https://github.com/lightningnetwork/lightning-rfc/blob/master/03-transactions.md[BOLT #3].] The scripts used in the Lightning Network are highly optimized and compact, to minimize the on-chain footprint, so they are not easy to read and understand.(((range="endofrange", startref="ix_appendix-bitcoin-fundamentals-review-asciidoc13"))) Nevertheless, see if you can identify some of the Bitcoin Script concepts we learned about in this chapter.(((range="endofrange", startref="ix_appendix-bitcoin-fundamentals-review-asciidoc12")))(((range="endofrange", startref="ix_appendix-bitcoin-fundamentals-review-asciidoc11")))(((range="endofrange", startref="ix_appendix-bitcoin-fundamentals-review-asciidoc0")))

[[htlc_script_example]]
.A complex script used in the Lightning Network
====
----
# To remote node with revocation key
DUP HASH160 <RIPEMD160(SHA256(revocationpubkey))> EQUAL
IF
    CHECKSIG
ELSE
    <remote_htlcpubkey> SWAP SIZE 32 EQUAL
    NOTIF
        # To local node via HTLC-timeout transaction (timelocked).
        DROP 2 SWAP <local_htlcpubkey> 2 CHECKMULTISIG
    ELSE
        # To remote node with preimage.
        HASH160 <RIPEMD160(payment_hash)> EQUALVERIFY
        CHECKSIG
    ENDIF
ENDIF
----
====
