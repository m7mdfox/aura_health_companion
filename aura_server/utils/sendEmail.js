// utils/sendEmail.js
import nodemailer from "nodemailer";
import dotenv from "dotenv";
dotenv.config();

const transporter = nodemailer.createTransport({
  host: "smtp.gmail.com",
  port: 587,
  secure: false, // true for 465, false for 587
  auth: {
    user: process.env.EMAIL_USER,
    pass: process.env.EMAIL_PASS,
  },
  tls: {
    rejectUnauthorized: false,
  },
  // Add this — CRITICAL for 2025
  requireTLS: true,
  greetingTimeout: 10000,
  socketTimeout: 10000,
  connectionTimeout: 10000,
  // This is the magic line many miss:
  authMethod: 'PLAIN',
});

export async function sendOTP(email, otp) {
  try {
    // First, verify connection
    await transporter.verify();
    console.log("SMTP connection verified");

   // Replace the mailOptions object in your sendOTP function with the following:

const mailOptions = {
  from: `"Aura Health" <${process.env.EMAIL_USER}>`,
  to: email,
  subject: "Your Aura Health Companion verification code",
  // email preheader (hidden in email clients, shows next to subject in inbox)
  // NOTE: some clients ignore this—it's included in the HTML as a hidden span.
  text: `Your Aura Health Companion verification code is ${otp}. It expires in 5 minutes.`,
  html: `
  <!doctype html>
  <html>
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width,initial-scale=1">
    <title>Aura Health - Verification Code</title>
  </head>
  <body style="margin:0; padding:0; background-color:#f4f6f8; font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;">
    <!-- Preheader : visible in inbox preview but hidden in email body -->
    <span style="display:none !important; visibility:hidden; mso-hide:all; font-size:1px; line-height:1px; max-height:0; max-width:0; opacity:0; overflow:hidden;">
      Your Aura Health Companion verification code — expires in 5 minutes.
    </span>

    <table role="presentation" cellpadding="0" cellspacing="0" width="100%" style="min-width: 100%; background-color: #f4f6f8;">
      <tr>
        <td align="center" style="padding: 24px;">
          <!-- Email container -->
          <table role="presentation" cellpadding="0" cellspacing="0" width="600" style="width:100%; max-width:600px; background:#ffffff; border-radius:12px; box-shadow: 0 6px 18px rgba(20,30,40,0.08); overflow:hidden;">
            <!-- Header -->
            <tr>
              <td style="padding:20px 24px; background: linear-gradient(90deg, #ffffff 0%, #f7fbff 100%);">
                <table role="presentation" width="100%" cellpadding="0" cellspacing="0">
                  <tr>
                    <td style="vertical-align:middle;">
                      <!-- Optional logo: set process.env.EMAIL_LOGO_URL to show -->
                      ${
                        process.env.EMAIL_LOGO_URL
                          ? `<img src="${process.env.EMAIL_LOGO_URL}" alt="Aura Health logo" width="120" style="display:block; border:0; outline:none; text-decoration:none;">`
                          : `<div style="display:inline-block; font-weight:700; color:#1f3b5a; font-size:18px;">Aura Health</div>`
                      }
                    </td>
                    <td align="right" style="vertical-align:middle; color:#8b9aa8; font-size:13px;">
                      Secure • Fast
                    </td>
                  </tr>
                </table>
              </td>
            </tr>

            <!-- Body -->
            <tr>
              <td style="padding:32px 28px;">
                <h1 style="margin:0 0 8px 0; font-size:20px; color:#102a43;">Your verification code</h1>
                <p style="margin:0 0 20px 0; color:#486581; font-size:15px; line-height:1.45;">
                  Use the code below to verify your account for Aura Health Companion. The code expires in <strong>5 minutes</strong>.
                </p>

                <!-- Code card -->
                <div style="margin:20px 0; padding:18px; text-align:center; border-radius:10px; background:linear-gradient(180deg,#f6fbff,#ffffff); border:1px solid #e6eef7; display:inline-block; min-width:220px;">
                  <div style="font-size:28px; letter-spacing:6px; color:#0b63a6; font-weight:700;">${otp}</div>
                </div>

                <!-- CTA button (optional) -->
                <div style="margin:24px 0;">
                  <a href="#" style="display:inline-block; text-decoration:none; padding:12px 18px; border-radius:8px; font-weight:600; font-size:14px; border:1px solid #0b63a6;">
                    Verify on the app
                  </a>
                </div>

                <p style="margin:0; color:#6b7c88; font-size:13px; line-height:1.5;">
                  If you didn't request this code, you can safely ignore this email. For help, reply to this message or visit our support page.
                </p>
              </td>
            </tr>

            <!-- Footer -->
            <tr>
              <td style="padding:18px 28px; background:#fbfdff; border-top:1px solid #eef4fb;">
                <table role="presentation" width="100%" cellpadding="0" cellspacing="0">
                  <tr>
                    <td style="font-size:12px; color:#93a3b3;">
                      Aura Health • Building healthier habits — <span style="white-space:nowrap;">© ${new Date().getFullYear()}</span>
                      <br>
                      <a href="mailto:support@aura.example" style="color:#0b63a6; text-decoration:none;">support@aura.example</a>
                    </td>
                    <td align="right" style="font-size:12px; color:#93a3b3;">
                      <a href="#" style="color:#93a3b3; text-decoration:none;">Privacy</a> &nbsp; • &nbsp; <a href="#" style="color:#93a3b3; text-decoration:none;">Unsubscribe</a>
                    </td>
                  </tr>
                </table>
              </td>
            </tr>

          </table>
          <!-- end container -->
        </td>
      </tr>
    </table>
  </body>
  </html>
  `,
};


    const info = await transporter.sendMail(mailOptions);
    console.log("OTP email sent successfully:", info.messageId);
  } catch (error) {
    console.error("Failed to send OTP email:", error.message);
    throw new Error("Email service temporarily unavailable");
  }
}