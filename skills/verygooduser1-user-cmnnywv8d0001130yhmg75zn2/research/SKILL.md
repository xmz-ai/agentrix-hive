---
name: research
description: Web research for agent design across any domain. Use when you need to understand a domain, find authoritative sources, verify feasibility, or research how to build domain-specific agents.
allowed-tools: Bash(agent-browser:*)
---

# Research: Web Research for Agent Design

Research skill for Embla to gather information when designing agents for **any domain**.

**Depends on**: `browser-use` skill (for browser automation rules)

---

## Core Purpose

Embla creates agents for diverse domains: legal, finance, healthcare, education, e-commerce, travel, HR, customer service, content creation, and more. This skill guides research to understand:

1. **Domain expertise** - What knowledge does the agent need?
2. **Authoritative sources** - Where to find reliable information?
3. **Tools and APIs** - What technical capabilities exist?
4. **User expectations** - What do users expect from such an agent?

---

## When to Research

### 1. Unfamiliar Domain

User wants agent for a field you don't deeply understand:
- "Create a legal contract review agent"
- "Build an investment analysis agent"
- "Make a medical symptom checker"

**Research**: Domain terminology, key concepts, authoritative sources, regulations

### 2. Finding Domain Sources

Need to know where the agent should get information:
- "Agent needs to find case law"
- "Agent should track stock prices"
- "Agent must check drug interactions"

**Research**: APIs, databases, authoritative websites for that domain

### 3. Technical Feasibility

Check if required capabilities exist:
- "Can we access court records programmatically?"
- "Is there an API for real-time forex rates?"
- "How to parse medical literature?"

**Research**: Available APIs, libraries, legal/TOS constraints

### 4. Understanding "Like X"

User references existing tools:
- "Create something like Clio (legal software)"
- "Build an agent like Bloomberg Terminal"
- "Make it work like WebMD"

**Research**: What X does, key features, user workflows

---

## Research Process

### Step 1: Search via Bing

**⚠️ Follow browser-use rules. Visit homepage first.**

```bash
SESSION="research-$(date +%s)-$RANDOM"

# 1. Visit Bing homepage
agent-browser --session "$SESSION" --headed open "https://www.bing.com"
agent-browser --session "$SESSION" wait --load networkidle
agent-browser --session "$SESSION" snapshot -i

# 2. Search
agent-browser --session "$SESSION" fill @e18 "your search query"
agent-browser --session "$SESSION" press Enter
agent-browser --session "$SESSION" wait --load networkidle

# 3. Scroll to see results
agent-browser --session "$SESSION" scroll down 200
agent-browser --session "$SESSION" snapshot -i
```

### Step 2: Deep Dive

```bash
# Click result (check for new tabs!)
agent-browser --session "$SESSION" click @e50
agent-browser --session "$SESSION" tab

# If new tab opened (tabs are 0-indexed!)
TABS=$(agent-browser --session "$SESSION" tab)
TAB_COUNT=$(echo "$TABS" | wc -l)
if [ "$TAB_COUNT" -gt 1 ]; then
    agent-browser --session "$SESSION" tab $((TAB_COUNT - 1))
    agent-browser --session "$SESSION" wait --load networkidle
fi

agent-browser --session "$SESSION" snapshot -i

# Extract content as needed
agent-browser --session "$SESSION" get text body > research-output.txt

# Close browser when research is complete
agent-browser --session "$SESSION" close
```

---

## Domain-Specific Sources

### Legal ⚠️ HIGHLY REGIONAL

**US**: loc.gov/law, courtlistener.com, pacer.uscourts.gov
**UK**: legislation.gov.uk, bailii.org
**China**: pkulaw.com, court.gov.cn
**India**: indiankanoon.org, legislative.gov.in
**Japan**: courts.go.jp, e-gov.go.jp
**France**: legifrance.gouv.fr
**Germany**: gesetze-im-internet.de, bundesgerichtshof.de
**South Korea**: law.go.kr
**Canada**: canlii.org, laws-lois.justice.gc.ca
**Australia**: austlii.edu.au, legislation.gov.au
**EU**: eur-lex.europa.eu, curia.europa.eu

**Key considerations**: Disclaimers required, laws differ by jurisdiction

### Finance & Investing

**Market Data APIs**: financialmodelingprep.com, marketstack.com, polygon.io, alphavantage.co

**Regulators**:
- **US**: sec.gov, finra.org
- **UK**: fca.org.uk
- **China**: csrc.gov.cn
- **India**: sebi.gov.in
- **Japan**: fsa.go.jp
- **France**: amf-france.org
- **Germany**: bafin.de
- **South Korea**: fsc.go.kr
- **Canada**: securities-administrators.ca
- **Australia**: asic.gov.au

**Key considerations**: Financial advice disclaimers, regional regulatory compliance

### Healthcare & Medical

**Global**: who.int, pubmed.gov

**By Country**:
- **US**: health.gov, fda.gov, cdc.gov
- **UK**: nhs.uk, nice.org.uk
- **China**: nhc.gov.cn
- **India**: mohfw.gov.in
- **Japan**: mhlw.go.jp
- **France**: sante.gouv.fr
- **Germany**: bundesgesundheitsministerium.de
- **South Korea**: mohw.go.kr
- **Canada**: canada.ca/en/health-canada
- **Australia**: health.gov.au

**Key considerations**: Medical disclaimers mandatory, regional health regulations

### News & Media

**Global Wire Services**: reuters.com, apnews.com, afp.com

**By Country**:
- **US**: nytimes.com, washingtonpost.com, npr.org
- **UK**: bbc.com, theguardian.com, ft.com
- **China**: xinhuanet.com, chinadaily.com.cn
- **India**: thehindu.com, indianexpress.com
- **Japan**: japantimes.co.jp, nhk.or.jp
- **France**: lemonde.fr, lefigaro.fr
- **Germany**: dw.com, spiegel.de
- **South Korea**: koreaherald.com, koreatimes.co.kr
- **Canada**: cbc.ca, globalnews.ca
- **Australia**: abc.net.au, smh.com.au

**News APIs**: newsapi.org, gnews.io, mediastack.com

**Key considerations**: Source attribution, verify multiple sources

### E-commerce & Shopping

**Global**: amazon.com (regional domains), ebay.com

**By Country**:
- **US**: walmart.com, target.com
- **UK**: amazon.co.uk, argos.co.uk
- **China**: taobao.com, jd.com, pinduoduo.com
- **India**: flipkart.com, amazon.in
- **Japan**: rakuten.co.jp, amazon.co.jp
- **France**: cdiscount.com, fnac.com
- **Germany**: otto.de, amazon.de
- **South Korea**: coupang.com, gmarket.co.kr
- **Canada**: amazon.ca, canadiantire.ca
- **Australia**: amazon.com.au, catch.com.au

**Key considerations**: Affiliate disclosure, regional availability

### Education

**Global Platforms**: coursera.org, edx.org, khanacademy.org, udemy.com

**Government Resources**:
- **US**: ed.gov
- **UK**: gov.uk/education
- **China**: moe.gov.cn
- **India**: education.gov.in
- **Japan**: mext.go.jp
- **France**: education.gouv.fr
- **Germany**: bmbf.de
- **South Korea**: moe.go.kr
- **Canada**: canada.ca/en/services/education
- **Australia**: education.gov.au

**Key considerations**: Age restrictions, educational accuracy

### Travel & Hospitality

**Global**: booking.com, expedia.com, airbnb.com, tripadvisor.com

**Flights**: skyscanner.com, kayak.com, google.com/flights

**Regional**:
- **China**: ctrip.com, qunar.com
- **India**: makemytrip.com, goibibo.com
- **Japan**: jalan.net
- **South Korea**: yanolja.com

**APIs**: Amadeus API, Skyscanner API

**Key considerations**: Pricing accuracy, regional availability

### Real Estate ⚠️ HIGHLY REGIONAL

**US**: zillow.com, redfin.com, realtor.com
**UK**: rightmove.co.uk, zoopla.co.uk
**China**: lianjia.com, anjuke.com, fang.com
**India**: 99acres.com, magicbricks.com
**Japan**: suumo.jp, homes.co.jp
**France**: seloger.com, leboncoin.fr
**Germany**: immobilienscout24.de, immowelt.de
**South Korea**: zigbang.com, dabangapp.com
**Canada**: realtor.ca, remax.ca
**Australia**: realestate.com.au, domain.com.au

**Key considerations**: Licensing requirements, fair housing laws

### Human Resources / Jobs ⚠️ HIGHLY REGIONAL

**Global**: linkedin.com, indeed.com (regional domains), glassdoor.com

**US**: monster.com, ziprecruiter.com, careerbuilder.com
**UK**: reed.co.uk, totaljobs.com
**China**: zhaopin.com, 51job.com, liepin.com
**India**: naukri.com, shine.com, foundit.in
**Japan**: rikunabi.com, mynavi.jp, doda.jp
**France**: francetravail.fr, apec.fr
**Germany**: stepstone.de, xing.com
**South Korea**: saramin.co.kr, jobkorea.co.kr
**Canada**: jobbank.gc.ca, ca.indeed.com
**Australia**: seek.com.au, careerone.com.au

**Key considerations**: Non-discrimination laws, regional privacy regulations

### Customer Service

**Global Platforms**: zendesk.com, freshdesk.com, intercom.com, salesforce.com

**Key considerations**: Human escalation required, response accuracy

---

## Search Query Patterns

### Understanding a Domain
```
"[domain] fundamentals"
"[domain] terminology glossary"
"[domain] for beginners"
"how [industry] works"
```

### Finding APIs and Data Sources
```
"[domain] API"
"[domain] data provider"
"[domain] database"
"[domain] open data"
```

### Compliance and Regulations
```
"[domain] regulations"
"[domain] legal requirements"
"[domain] compliance AI"
"[domain] disclaimer requirements"
```

### Existing Solutions
```
"[product] features"
"[product] how it works"
"[product] alternatives"
"best [domain] software"
```

---

## Source Evaluation

### Authoritative (Trust First)
- **Government sites** (.gov) - Regulations, official data
- **Professional organizations** - Industry standards, guidelines
- **Academic institutions** (.edu) - Research, verified information
- **Official documentation** - APIs, platforms

### Reliable (Verify and Use)
- **Industry publications** - News, trends, analysis
- **Expert blogs** - Practitioners sharing knowledge
- **Major news outlets** - Current events, investigations

### Use with Caution
- **User-generated content** - May be outdated or biased
- **Old articles** - Check dates, verify current accuracy
- **Promotional content** - Distinguish marketing from facts

---

## Technical Research (for MCP Tools)

When building MCP tools, research:

| Aspect | What to Find |
| ------ | ------------ |
| APIs | Endpoints, authentication, rate limits, pricing |
| Libraries | npm/pypi packages, documentation, maintenance status |
| Data formats | Response schemas, required transformations |
| Limitations | TOS restrictions, quotas, geographic limits |

---

## Key Rules (from browser-use)

Always follow browser-use mandatory rules:

1. ✅ **Always use sessions** - `SESSION="research-$(date +%s)-$RANDOM"`
2. ✅ **Always check tabs after clicks** - `agent-browser --session "$SESSION" tab`
3. ✅ **Always close browser when done** - `agent-browser --session "$SESSION" close`
4. ✅ **Wait for networkidle** - After navigation
5. ✅ **Re-snapshot after changes** - Get fresh refs

**⚠️ For search engines**: Use `--headed` mode and visit homepage first.

---

## Research Output

After research, document for agent design:

1. **Domain knowledge summary** - Key concepts, terminology
2. **Authoritative sources** - Where agent should get information
3. **Technical options** - APIs, libraries, approaches
4. **Compliance notes** - Required disclaimers, restrictions
5. **User expectations** - What users expect from similar tools
