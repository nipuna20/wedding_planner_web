import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
      ),
      body: const PrivacyPolicyContent(),
    );
  }
}

class PrivacyPolicyContent extends StatelessWidget {
  const PrivacyPolicyContent({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        Text(
          'Atchadhai Privacy Policy\nEffective: June 11, 2025',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 16),
        PolicySection(
          title: 'Introduction',
          content:
              'This Privacy Policy describes the data protection practices of Atchadhai (“AT,” “we,” “us,” or “our”). AT provides services to users throughout the world and is the data controller of your information. This Privacy Policy applies to the Atchadhai.com Web and mobile Web pages, the Atchadhai mobile app and associated Atchadhai websites and mobile applications owned and operated by us or our affiliates that link to this Privacy Policy (“Affiliates”), and related Atchadhai branded online and offline services thereto (the “Services”).\n\n'
              'PLEASE READ THIS PRIVACY POLICY CAREFULLY TO UNDERSTAND HOW WE HANDLE YOUR INFORMATION. IF YOU DO NOT AGREE TO THIS PRIVACY POLICY, PLEASE DO NOT USE THE SERVICES.',
        ),
        PolicySection(
          title: 'A. The Information We Collect and the Ways We Use It',
          content:
              'We obtain information about you through the means discussed below when you use our Services. The information we collect and the purposes for which we use it will depend to some extent on the specific Services you use and how you interact with AT. The following describes the categories of information about you that we collect and how we collect and use such information.\n\n'
              'Categories of Information Collected | Purposes of Use | Sources of Personal Information\n'
              '--- | --- | ---\n'
              'Contact and account registration information, e.g., name, email address, postal address, phone number, wireless device address, account username or screen name, and password | • Provide the Services\n• Communicate with you\n• Personalize your experience\n• Secure our Services and users\n• Fraud prevention and legal purposes | • You\n• Other users who provide information about you in connection with their event or profile\n• Consumer data resellers\n• Public records databases\n• Conferences and other events\n• Our Affiliates\n'
              'Demographic and statistical information, e.g., gender, interests, lifestyle information, and hobbies | • Communicate with you\n• Provide the Services\n• Personalize your experience | • You\n• Other users who provide information about you in connection with their event or profile\n• Consumer data resellers\n• Our Affiliates\n• Social media networks, in accordance with your privacy preferences on such services\n'
              'Financial and transactional information, e.g., shipping address, credit or debit card number, verification number, and expiration date, and information about your transactions and purchases with us | • Communicate with you\n• Provide the Services\n• Secure our Services and users\n• Fraud prevention and legal purposes | • You\n• Third-party payment processors who collect this information on our behalf and who also have an independent relationship with you\n• Third party suppliers and sellers\n'
              'User-generated content, e.g., photos, videos, audio, information about your events, any information you submit in public AT forums or message boards, reviews you leave for vendors, and feedback or testimonials you provide about our Services | • Provide the Services\n• Communicate with you\n• Personalize your experience\n• Secure our Services and users\n• Fraud prevention and legal purposes | • You\n• Other users who provide information about you in connection with their event or profile\n'
              'Customer service information, e.g., questions and other messages you address to us directly through online forms, by email, over the phone, or by post; and summaries or voice recordings of your interactions with customer care | • Communicate with you\n• Provide the Services\n• Secure our Services and users\n• Fraud prevention and legal purposes | • You\n• Other Affiliates\n'
              'Communications with event vendors and partners, e.g., your in-Services messages and calls to vendors and advertising partners, and information surrounding those messages such as the date/time of the communication, the originating number, the recipient number, the duration of a call, and your location as determined by your area code | • Provide the Services\n• Secure our Services and users\n• Fraud prevention and legal purposes | • You\n• The event vendors with which you communicate\n'
              'Research, survey, or sweepstakes information, e.g., if you participate in a survey or sweepstakes, we collect information needed for you to participate (such as contact information), and to fulfill your prize | • Communicate with you\n• Provide the Services\n• Secure our Services and users\n• Fraud prevention and legal purposes | • You\n• Survey or sweepstakes partners\n• Researchers and analysts\n'
              'Information about others, e.g., if you use a “tell-a-friend” tool (or similar feature) that allows you to send information to another person, or invite them to participate in an event, web site, registry or other property, or include their information within our products as part of your wedding planning experience (for example so they may receive save the date and RSVP notifications and wedding invitations) we will collect, at a minimum, the recipient’s email address; or, if you provide us with information about other people involved in your events (such as your fiancé, partner, or guests). In providing this information, you represent that you are authorized to provide it. | • Provide the Services\n• Personalize your experience\n• Fraud prevention and legal purposes | • You\n• Other users (if you are the recipient of a communication)\n• Our Affiliates\n'
              'Device information and identifiers, e.g., IP address; browser type and language; operating system; platform type; device type; software and hardware attributes; and unique device, advertising, and app identifiers | • Provide the Services\n• Personalize your experience\n• Secure our Services and users\n• Fraud prevention and legal purposes | • You\n• Advertising providers\n• Analytics providers\n• Cookies and tracking technologies\n'
              'Connection and usage data, e.g., information about files you download, domain names, landing pages, browsing activity, content or ads viewed and clicked, dates and times of access, pages viewed, forms you complete or partially complete, search terms, uploads or downloads, whether you open an email and your interaction with email content, access times, error logs, and other similar information | • Provide the Services\n• Personalize your experience\n• Secure our Services and users\n• Fraud prevention and legal purposes | • You\n• Advertising providers\n• Analytics providers\n• Cookies and tracking technologies\n• Marketers\n• Our Affiliates\n'
              'Geolocation, e.g., city, state, country, and ZIP code associated with your IP address or derived through Wi-Fi triangulation; and, with your permission in accordance with your mobile device settings, and precise geolocation information from GPS-based functionality on your mobile devices | • Provide the Services\n• Personalize your experience\n• Secure our Services and users\n• Fraud prevention and legal purposes | • You\n• Advertising providers\n• Analytics providers\n• Marketers\n• Our Affiliates\n'
              'Social media information, e.g., if you access the Services through a third-party connection or log-in, we may have access to information you provide to that social network such as your name, email address, friend list, photo, gender, location, and current city; and information you provide to us directly through our pages on social networking and blogging platforms (e.g., Facebook, Instagram, Snapchat, Wordpress, and Twitter) | • Provide the Services\n• Communicate with you\n• Personalize your experience\n• Secure our Services and users\n• Fraud prevention and legal purposes | • You\n• Social media networks, in accordance with your privacy preferences on such services\n'
              'Other information, e.g., any other information you choose to directly provide to AT in connection with your use of the Services | • Provide the Services\n• Communicate with you\n• Personalize your experience\n• Secure our Services and users\n• Fraud prevention and legal purposes | • You\n\n'
              'The following provides additional information about the purposes and legal bases for collecting and using your information:\n'
              'Purposes of Use | Legal Basis\n'
              '--- | ---\n'
              'Communicate with you, for example:\n• Responding to your requests for information and provide you with more effective and efficient customer service and technical support\n• Providing you with transactional updates and information about the Services (e.g., inform you about updates to our Services, information about your account, or information about ecommerce transactions that you conduct on the Services)\n• In accordance with applicable legal requirements, contacting you by email, postal mail, phone, or SMS regarding AT, our Affiliates, and third-party products, services, surveys, promotions, special events and other subjects that we think may be of interest to you | • Our Legitimate Business Interests\n• With Your Consent\n'
              'Provide the Services, for example:\n• Processing and fulfilling your transactions\n• Assisting you in submitting or requesting a vender quote\n• Providing community features and posting your content, including any testimonials you provide\n• Engaging in analysis, research, and reports to better understand how you use the Services, so we can improve them\n• Administering entries into sweepstakes, contests, promotions, or surveys\n• Sending communications that you have requested on your behalf, such as if you request to connect your profile with a family member or friend or send a tell-a-friend or vendor message\n• Understanding and resolving app crashes and other issues being reported | • Performance of a contract – to provide the Services to you\n• Our Legitimate Business Interests\n'
              'Personalize your experience, for example:\n• Customizing the advertising and content on the Services based on your activities and interests\n• Creating and updating audience segments that can be used for targeted advertising and marketing on the Services, third party services and platforms, and mobile apps\n• Creating profiles about you, including adding and combining information we obtain from third parties, which may be used for analytics, marketing, and advertising\n• Sending you personalized newsletters, surveys, and information about products, services and promotions offered by us, our partners, and other organizations with which we work | • Our Legitimate Business Interests\n• With Your Consent\n'
              'Secure our Services and users, for example:\n• Monitoring, preventing, and detecting fraud, such as through verifying your identity\n• Combatting spam or other malware or security risks\n• Monitoring, enforcing, and improving the security of our Services | • Our Legitimate Business Interests\n• To Comply with Legal Obligations and Protect Our Legal Rights\n'
              'Fraud detection and prevention, defending our legal rights and compliance with the law, for example:\n• Complying with any applicable procedures, laws, and regulations where it is necessary for our legitimate interests or the legitimate interests of others\n• Establishing, exercising, or defending our legal rights where it is necessary for our legitimate interests or the legitimate interests of others (e.g., to enforce compliance with our Terms of Use, Privacy Policies, or to protect our Services, users, or others) | • Our Legitimate Business Interests\n• To Comply with Legal Obligations and Protect Our Legal Rights\n'
              'Combined Information: For the purposes discussed in this Privacy Policy, we may combine the information that we collect through the Services with information that we receive from other sources, both online and offline, and use such combined information in accordance with this Privacy Policy.',
        ),
        PolicySection(
          title: 'B. Cookies and Online Analytics',
          content:
              'We use a variety of online tracking and analytics tools (e.g., cookies, flash cookies, pixel tags, and HTML5) to collect and analyze information as you use the Services. Among other things, these technologies allow us to offer you a more tailored experience in the future, by understanding and remembering your particular browsing and usage preferences.\n\n'
              'We may also use third-party web analytics services (such as those of Google Analytics, Coremetrics, Mixpanel, and Segment) on our Services to collect and analyze information collected through these technologies to assist us in auditing, research, or reporting; fraud prevention; and providing certain features to you. To find out more about how your usage information is collected through the practices of, and how you may be able to opt out of certain information by, such third parties, click here. The types of tracking and analytics tools we and our service providers use for these purposes are:\n'
              '• “Cookies” are small data files stored on your computer or device to collect information about your use of the Services. Cookies may enable us to recognize you as the same user who used our Services in the past, and relate your use of the Services to other information we have about you. Cookies may also be used to enhance your experience on the Services (for example, by storing your username) and/or to collect general usage and aggregated statistical information. Most browsers can be set to detect cookies and give you an opportunity to reject them, but refusing cookies may, in some cases, limit your use of our Services or features. To learn more about the use of cookies, including how to manage or delete them, click here. Please note that by blocking, disabling, or managing any or all cookies, you may not have access to certain features or offerings of the Services.\n'
              '• “Local shared objects,” or “flash cookies,” may be stored on your computer or device using a media player or other software. Local shared objects operate much like cookies, but cannot be managed in the same way. Depending on how local shared objects are enabled on your computer or device, you may be able to manage them using software settings. For information on managing flash cookies, for example, click here.\n'
              '• A “pixel tag” (also known as a “clear GIF” or “web beacon”) is a tiny image – typically just one-pixel – that can be placed on a web page or in our electronic communications to you in order to help us measure the effectiveness of our content by, for example, counting the number of individuals who visit us online or verifying whether you’ve opened one of our emails or seen one of our web pages.\n'
              '• “HTML5” (the language some websites, such as mobile websites, are coded in) may be used to store information on your computer or device about your usage of the Services so that we may improve and customize them for you.',
        ),
        PolicySection(
          title: 'C. Online Advertising',
          content:
              '1. Online Advertising Overview\n'
              'The Services may integrate third-party advertising technologies that allow for the delivery of relevant content and advertising on the Services, as well as on other websites you visit and other applications you use. The ads may be based on various factors such as the content of the page you are visiting, your searches, demographic data, user-generated content, and other information we collect from you. These ads may be based on your current activity or your activity over time and across other websites and online services and may be tailored to your interests.\n\n'
              'Third parties, whose products or services are accessible or advertised via the Services, may also place cookies or other tracking technologies on your computer, mobile phone, or other device to collect information about you as discussed above. We also allow other third parties (e.g., ad networks and ad servers such as Google and others) to serve tailored ads to you on the Services, other sites, and in other applications, and to access their own cookies or other tracking technologies on your computer, mobile phone, or other device you use to access the Services. We sometimes provide our customer information (such as email addresses) to service providers, who may “match” this information in de-identified form to cookies (or mobile ad identifiers) and other proprietary IDs, in order to provide you with more relevant ads when you visit other websites and mobile applications.\n\n'
              'We neither have access to, nor does this Privacy Policy govern, the use of cookies or other tracking technologies that may be placed on your device you use to access the Services by such non-affiliated third parties. If you are interested in more information about tailored browser advertising and how you can generally control cookies from being put on your computer to deliver tailored advertising, you may visit the Network Advertising Initiative’s Consumer Opt-Out link, the Digital Advertising Alliance’s Consumer Opt-Out link, or Your Online Choices to opt-out of receiving tailored advertising from companies that participate in those programs. To opt out of Google Analytics for display advertising or customize Google display network ads, visit the Google Ads Settings page. We do not control these opt-out links or whether any particular company chooses to participate in these opt-out programs. We are not responsible for any choices you make using these mechanisms or the continued availability or accuracy of these mechanisms.\n\n'
              'Please note that if you exercise the opt out choices above, you will still see advertising when you use the Services, but it will not be tailored to you based on your online behavior over time.\n\n'
              '2. Mobile Advertising\n'
              'When using mobile applications from AT or others, you may also receive tailored in-application advertisements. We may use third-party service providers to deliver advertisements on mobile applications or for mobile application analytics. Each operating system, iOS for Apple phones, Android for Android devices, and Windows for Microsoft devices provides its own instructions on how to prevent the delivery of tailored in-application advertisements. We do not control how the applicable platform operator allows you to control receiving personalized in-application advertisements; thus, you should contact the platform provider for further details on opting out of tailored in-application advertisements. You may review the support materials and/or the device settings for the respective operating systems to opt-out of tailored in-app advertisements.\n\n'
              '3. Notice Concerning Do Not Track\n'
              'Do Not Track (“DNT”) is a privacy preference that users can set in certain web browsers. We are committed to providing you with meaningful choices about the information collected on our website for online advertising and analytics purposes, and that is why we provide the variety of opt-out mechanisms listed above. However, we do not currently recognize or respond to browser-initiated DNT signals. Learn more about Do Not Track.',
        ),
        PolicySection(
          title: 'D. How We Share and Disclose Your Information',
          content:
              'AT will share the information collected from and about you as discussed above for various business purposes. The following explains the categories of third parties with which we may share your information, and the categories of information we may share with each:\n\n'
              'Third Parties with which we share information and why | Categories of information shared\n'
              '--- | ---\n'
              'Our Affiliates: We may share information we collect within the AT family of companies to deliver products and services to you, ensure a consistent level of service across our products and Services, and enhance our products, services, and your customer experience | • All categories of information we collect may be shared with our Affiliates\n'
              'Service Providers that Perform Services on our Behalf: We may share information with service providers, including billing and payment processing, sales, marketing, advertising, data analysis and insight, research, technical support and customer service, shipping and fulfillment, data storage, security, fraud prevention, and legal services providers | • All categories of information we collect may be shared with our service providers\n'
              'Other Individuals, Services, and Vendors at Your Request: We will share your information with other individuals and services at your request. For example, if you communicate with a vendor you connect with through the Services, we may share information, as well as the contents of your message, so that the vendor may contact you pursuant to such vendor’s privacy policy and applicable legal agreements. Moreover, if you participate in one of our registry programs, we will share your information with your friends, families, and other contacts as well as the registry program participants | • Geolocation\n• Other Information\n'
              'Third Party Partners for Marketing Purposes: We may share your information with partners whose offerings we think may interest you. For example, if you participate in a registry program, or register for certain of our Services, we may share information with our Affiliates and other third parties (organizations that have offerings we think may interest you, registry program participants, retailers, other program participants, or other third-parties) for their marketing and other purpose | • Contact and account registration\n• Demographic and statistical information\n• Geolocation\n• Other Information\n'
              'Third Party Partners to Provide Co-Branded Products and Services: In some cases, we may share information with third-party partners to provide co-branded products or services, including contests, sweepstakes, and joint activities. For example, if you choose to interact with such co-branded products or services using your account information with us, we may share your account information with third parties as required to provide the co-branded product or service that you request, including any information required for contest prize fulfillment | • Contact and account registration\n• Demographic and statistical information\n• Financial and transactional information\n• User-generated content\n• Research, survey, or sweepstakes information\n• Geolocation\n• Other Information\n'
              'Third Parties for Legal Purposes: By using the Services, you acknowledge and agree that we may access, retain, and disclose the information we collect and maintain about you if required to do so by law or in a good faith belief that such access, retention or disclosure is reasonably necessary to: (a) comply with legal process or a regulatory investigation (e.g. a subpoena or court order); (b) enforce our Terms of Service, this Privacy Policy, or other contracts with you, including investigation of potential violations thereof; (c) respond to claims that any content violates the rights of third parties; and/or (d) protect the rights, property or personal safety of AT, its agents and Affiliates, its users and/or the public. This includes exchanging information with other companies and organizations for fraud protection, and spam/malware prevention, and similar purposes | • All categories of information we collect may be shared for legal purposes\n'
              'Third Parties in a Business Transaction: We may disclose or transfer information in connection with a corporate transaction, including for example a merger, investment, acquisition, reorganization, consolidation, bankruptcy, liquidation, or sale of some or all of our assets | • All categories of information we collect may be shared in connection with a business transaction\n'
              'Third-Party Online Advertisers and Ad Networks: As discussed in the “Online Advertising” Section above, the Services may integrate third-party advertising technologies that allow for the delivery of relevant content and advertising on the Services, as well as on other websites you visit and other applications you use, and these technologies will collect certain information from your use of the Services to assist in delivering such ads | • Demographic and statistical information\n• User-generated content\n• Device information and identifiers\n• Connection and usage data\n• Geolocation\n• Social media information\n',
        ),
        PolicySection(
          title: 'E. Notice About Use of Our Forums and Features',
          content:
              'Certain features of our Services make it possible for you to share comments publicly and privately with other users, such as through our public forums, chat rooms, blogs, personal messages, review features, and message boards. You should be aware that any information you provide or post in these ways may be read, collected, and used by others who access them. While we do not have an obligation to monitor the content of messages sent using our Services, we reserve the right to, in our discretion. We encourage you to be cautious about the information you submit (e.g., choose a username that does not disclose your personal identity). Whenever you post something in our Services, social media and any other third party platforms we control, it may be impossible to remove all instances of the posted information, for example, if someone has taken a screenshot of your posting. You may be required to register with a third-party application to post a comment. Moreover, please note that if you participate in one of our registry programs, in some instances, you can choose to make your registries available only to guests and friends via a password. If you do not elect this option, then any user will be able to search for and view your registry by using your first and/or last name and other information regarding your event.',
        ),
        PolicySection(
          title: 'F. Aggregate and De-Identified Information',
          content:
              'We may aggregate and/or de-identify any information collected through the Services so that such information can no longer be linked to you or your device (“Aggregate/De-Identified Information”). We may use Aggregate/De-Identified Information for any purpose, including without limitation for research and marketing purposes, and may also share such data with any third parties, including advertisers, promotional partners, and sponsors, in our discretion.',
        ),
        PolicySection(
          title: 'G. Your Choices and Rights',
          content:
              'Depending on where you reside, you may have the following privacy rights, subject to any applicable exemptions or limitations:\n'
              'a. Right to Correct: You have the right to request that we correct inaccurate Personal Information that we maintain about you.\n'
              'b. Right to Delete: You have the right to request that we delete your Personal Information.\n'
              'c. Right to Know: You have the right to request that we disclose (1) the categories and/or specific pieces of Personal Information we collect about you; (2) the categories of sources from which we collect Personal Information; (3) the purpose for collecting, Selling, or Sharing your Personal Information; (4) the categories of Personal Information we Sold, Shared, or disclosed; (5) the categories of third parties to which we Sold, Shared or disclosed Personal Information.\n'
              'd. Right to Opt Out of Sale or Sharing: You have the right to request to opt out of Sale or Sharing of your Personal Information.\n'
              'e. Right to Opt Out of Profiling, Targeted Advertising, or Automated Decision-Making: You have the right to request to opt out of profiling, targeted advertising, or automated decision-making.\n'
              'f. Right to Appeal: You have the right to appeal in case we decide to deny your request by emailing us at the address below.\n\n'
              'If you choose to exercise any of these rights, AT will not discriminate against you. However, please note that if you exercise your rights, you may be unable to use or access certain features of the AT’s Sites or Services.\n\n'
              'If you would like to exercise any of your rights, please submit a verifiable request to us by contacting us at support@atchadhai.com\n\n'
              'If you would like to opt out of the Sale or Sharing of your Personal Information, please use the “Do Not Sell My Personal Information” link in the Site footer. You can also submit a sale opt-out request by emailing us at request@atchadhai.com. In addition, you must complete this step on each device and browser from which you visit our Sites to fully opt out of Sale or Sharing of your Personal Information. If you delete or clear your cookies or other tracking technologies, you would need to resubmit your request to opt out of Sale or Sharing of Personal Information. If you block your cookies or other tracking technologies, we will be unable to process your opt out request.\n\n'
              'Verification: Either you or your authorized agent may submit a privacy request related to your Personal Information. We will request you provide us with information necessary to verify your identity before responding to your request. If required, we may request additional information to verify your identity.\n\n'
              'Authorized Agents: To process privacy requests from your authorized agent, we will verify your and your authorized agent’s identity. This may require us to request a signed declaration from you that authorizes your agent to submit a privacy request on your behalf. We will deny a request from an authorized agent, if we do not receive proof that they have been authorized by you to submit a privacy request related to your Personal Information.\n\n'
              'Testimonials/Notable Quotes: On some of our Services, and with your consent, we post notable quotes or testimonials which may contain information such as your name, event type, city, state, and quote or testimonial. Requests for removal of a user testimonial can be done by contacting us as detailed in the “Contact Information” section below.',
        ),
        PolicySection(
          title: 'H. Jurisdiction Specific Information',
          content:
              'This section is intentionally left blank as no specific jurisdiction-related information was provided in the Privacy Policy document.',
        ),
        PolicySection(
          title: 'I. Third Party Links and Features',
          content:
              'The Services may contain links, banners, widgets or advertisements (e.g., a “Share It!” or “Like” button) that lead to other websites, apps, or services not subject to this Privacy Policy (including other sites that may be co-branded with our brands). On some of our Services, you may also be able to register with or purchase directly from third-party retailers. We are not responsible for the privacy practices or the content of any other websites to which the Services link or which link to our Services. The privacy policies of these other sites will govern the collection and use of your information thereon, and we encourage you to read each such policy to learn about how your information may be treated by others.',
        ),
        PolicySection(
          title: 'J. Children’s Privacy',
          content:
              'The Services are intended for general audiences and not for children under the age of 18. If we become aware that we have collected “personal information” (as defined by the Sri Lanka’s Online Privacy Protection Act) from children under the age of 18 without legally-valid parental consent, we will take reasonable steps to delete it as soon as possible. We do not knowingly process data of EU residents under the age of 16 without parental consent. If we become aware that we have collected data from an EU resident under the age of 16 without parental consent, we will take reasonable steps to delete it as soon as possible. We also comply with other age restrictions and requirements in accordance with applicable local laws.',
        ),
        PolicySection(
          title: 'K. International Users',
          content:
              'Our Services are targeted to individuals located in the Sri Lanka. Please note that in providing services to you, your information will be transferred to Sri Lanka. Moreover, AT may subcontract the processing of your data to, or otherwise share your data within the AT family of companies, trusted service providers, and trusted business partners located in countries other than your country of residence, in accordance with applicable law. Such third parties may be engaged in, among other things, the provision of Services to you, the processing of transactions and/or the provision of support services. By providing us with your information, you acknowledge any such transfer, storage or use.',
        ),
        PolicySection(
          title: 'L. How We Protect Your Information',
          content:
              'We take a variety of physical, technical, administrative, and organizational security measures to protect your information against accidental or unlawful destruction or accidental loss, alteration, unauthorized disclosure or access. However, no method of transmission over the Internet, and no means of electronic or physical storage, is absolutely secure. As such, you acknowledge and accept that we cannot guarantee the security of your information transmitted to, through, or on our Services or via the Internet and that any such transmission is at your own risk.\n\n'
              'When you sign up for an account, you may be required to establish a username and password. If you create an account with us, you are responsible for maintaining the confidentiality of your account password and for any activity that occurs under your account. We are not responsible for any loss or damage arising from your failure to maintain the confidentiality of your password.\n\n'
              'If you use messaging or call features that allow you to interact with events vendors and others directly through our Services, please note that for security purposes, you should not include any passwords, social security numbers, payment card information, or other sensitive information in such communications.',
        ),
        PolicySection(
          title: 'M. Retention of Your Information',
          content:
              'We store and maintain your information for the purposes for which it is processed by us. The length of time for which we retain information depends on the purposes for which we collected and use it and/or as required to comply with applicable laws.',
        ),
        PolicySection(
          title: 'N. Changes to Our Privacy Policy',
          content:
              'We reserve the right to amend this Privacy Policy to reflect changes in the law, our data collection and use practices, the features of our Services, or advances in technology. We will make the revised Privacy Policy accessible through the Services, so you should review the Policy periodically. You can know if the Privacy Policy has changed since the last time you reviewed it by checking the “Effective Date” included at the beginning of the document. If we make a material change to the Policy, you will be provided with appropriate notice in accordance with legal requirements. By continuing to use the Services, you are confirming that you have read and understood the latest version of this Privacy Policy.',
        ),
        PolicySection(
          title: 'O. AT Contact Information',
          content:
              'If you have any questions or comments regarding our privacy practices, you can contact us at support@atchadhai.com.\n'
              'By mail: 125, Elakanda Road, Hendala, Wattala, Sri Lanka',
        ),
      ],
    );
  }
}

class PolicySection extends StatelessWidget {
  final String title;
  final String content;

  const PolicySection({required this.title, required this.content, super.key});

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(content, style: const TextStyle(fontSize: 14)),
        ),
      ],
    );
  }
}