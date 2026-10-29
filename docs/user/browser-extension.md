# The browser extension

The DLM extension for Chrome (and Edge, Brave, Opera, Vivaldi) and Firefox sends the downloads of
your browser to DLM, so they use DLM's speed, queues and resume. It is released on
[GitHub](https://github.com/sabadia/dlm-extension/releases/latest) first; browser stores come later.
**Get the extension** in *Setup* opens that page.

## Connecting the extension to the app

1. Install the extension in your browser and open it.
2. Choose **Connect**. DLM comes to the front and asks **Allow a browser extension?** with a
   six-digit code.
3. Check that the code is the one the extension shows, then choose **Allow**. Choose **Deny** if you
   did not start this.

A request nobody answers ends after two minutes. Each extension gets a token of its own, which can
only add and control downloads: it cannot change settings, manage other tokens or read your
cookies back. Only the DLM on this computer pairs extensions, so a remote profile has no pairing.

## Registering the browsers

The extension finds DLM through a small registration in each browser. Under **Manage ▸ Access ▸
Browser extension** tick the browsers you use (none ticked means all) and choose **Install**. DLM registers the published
extension; it renews the registration each time it starts (so moving the app is harmless) and
removes it when you uninstall DLM. **Remove** takes it out by hand.

## Seeing and removing paired extensions

**Manage ▸ Access ▸ Browser extensions** lists every paired extension with its browser, version and
when it last connected. **Revoke** ends that extension's access at once; nothing else is affected.
*Setup* shows how many are paired.

## When a link has expired

If a download's link expires and DLM cannot renew it alone, the download waits and DLM shows
**Waiting for a new link**, with a notification. Choose **Open the page** (or the button of the
notification) to open the page the download came from in your browser; start the download there
again and the extension hands it to the same task, which carries on from where it stopped.

## Uninstalling

The Windows uninstaller, the Homebrew `zap` and the `.deb`/`.rpm` removal take the registrations out.
If you removed DLM another way, run `dlm native-host uninstall` or delete `dev.sabadia.dlm.json` from
the `NativeMessagingHosts` folder of your browser.
