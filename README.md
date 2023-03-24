# Practical key-recovery attack on MQ-Sign
This reposity contains verification scripts and an explanatory note on a practical key-recovery attack on the MQ-Sign digital signature scheme, a candidate in the Korean Post-Quantum Cryptography Competition.

This is joint work with [Thomas Aulbach](https://www.uni-regensburg.de/informatics-data-science/qpc/team/thomas-aulbach/index.html), [Simona Samardjiska](https://samardjiska.org/) and [myself](https://mtrimoska.com/).

### Running the scripts

Use ``` magma attack_MQ-Sign.magma ``` for the Magma script.

Use ``` sage attack_MQ-Sign.sage ``` for the SageMath script.

The scripts are set to run an attack of the security level I by default. This can be modified in the ```Params setup``` section at the beginning of the script. Set ```__SEC_LEVEL__``` to 3 or 5, or specify the values of ```q``` , ```v``` and ```m``` and keep ```__SEC_LEVEL__``` to a value different than 3 or 5.

The scripts will output ```True``` if the secret key found through the attack corresponds to the secret key obtained from key generation.
