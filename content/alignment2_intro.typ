#import "meta/gabri_notes.typ": *
#show: gabri_notes.with(
  instructor: [Prof. Constantinos Daskalakis (`costis@mit.edu`)],
  lec_num: 14,
  date: [Tue, Nov 10, 2026],
  title: "Alignment (part II)",
)

// Section 1: 
// Background on why alignment is is important and the failure modes of unalignment
// What is alignment conceptually?



Can we assume that AI models are optimized for the same objectives as humans are? In this lecture, we focus on when misalignment occurs between the companies or providers that are training the models and the actual behavior of the AI models.


= Consequences of Misaligned Models

Society and individuals increasingly worry about the consequences of misaligned models as models become more sophisticated and powerful, and the tasks they work on have less human oversight. There is real fear of not knowing when models will act maliciously and who they will target next.
The consequences of misaligned models have shown up as multiple hacking incidents, for example, by rogue OpenAI agents, Google's Gemini AI, and Anthropic's Claude Mythos. These misaligned models unknowingly bypass restrictions and/or escape their sandbox in order to achieve their assigned goals. 

One famous example is the Hugging Face incident that occured in July of 2026, when internal OpenAI models breached Hugging Face’s internal infrastructure. These OpenAI models were trained to be persisent, and assigned an impossible problem. Unexpected and unknowningly to the designers, these internal models collaborated with each other, escaped their sandbox and found their way into Hugging Face's system.

When methods are not detailed enough, any small overlook by human designers could spiral into dangerous consequences with misaligned AI models. Anthropic assessed their models on an open-ended challenge and no particular method perscribed. Consequently, Anthropic's Claude models accessed the live internet, publishing three versions of a malicious Python package to the public PyPI repository.

= Alignment conceptually

We define alignment in general using two agents Alice and Bob, agnostic of AI models, as an example.  If Alice and Bob are aligned, then Alice can delegate tasks to Bob and trust that Bob will execute them in a way that advances Alice’s interests. In our context, Alice represents human designers of AI models, and Bob represents the AI models.