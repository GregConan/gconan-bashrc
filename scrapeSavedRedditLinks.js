/* Greg Conan
 * Reddit Saved Content Scraping Tool
 * Created 2024-12-02
 * Updated 2024-12-21
 */

/**
 * @param {*} txtLine String of text for Markdown-formatted inline link to show
 * @param {*} eachAhref String, hyperlink to add to txtLine as an inline link
 * @returns String of properly Markdown-formatted text with an inline link
 */
function toMdLink(txtLine, eachAhref) {
    // Given a line of text and a hyperlink, both strings, return a properly
    // form
    return "[" + txtLine.replaceAll(/\[/g, String.fromCharCode(92) + "["
                       ).replaceAll(/\]/g, String.fromCharCode(92) + "]"
                       ).replaceAll(/\\{2,}/g, '\\') + "](" + eachAhref + ")";
} // toMdLink

/**
 * @param {*} shred 1 post's DOM object on the Reddit saved links page
 * @returns String containing the post's title and links in Markdown format
 */
function postToMarkdown(shred) {
    let result = toMdLink(shred.postTitle, shred.contentHref);
    let shredSrc = shred.hasAttribute("href") ? shred.href : shred.permalink;
    return result + " ([via Reddit](https://reddit.com" + shredSrc + "))";
} // postToMarkdown

/**
 * @param {*} shred 1 comment's DOM object on the Reddit saved links page
 * @returns String containing the comment, with its links, in Markdown format
 */
function commentToMarkdown(shred) {
    let result;
    let anchors = Array.from(shred.getElementsByTagName("a")
                             ).filter(eachA => ! eachA.host.includes("reddit"));
    // let extAnchors = Array.from(anchors).filter( eachAnchor => eachAnchor.href.startsWith("http") ); 
    // let extNonReddit = extAnchors.filter( eachA => ! eachA.host.includes("reddit") );

    let outLines = shred.outerText.trim().split(/[\n\r]+/);  // TODO Or shred.outerText.trim().split(eachA.innerText) ?
    let ixAnchor = 0;
    for (let i = 0; i < outLines.length; i++) {
        // TODO
        let eachA = anchors[ixAnchor];
        let txtLine;
        let txtToFind = eachA.outerText.trim();
        let lineSplit = outLines[i].split(eachA.href);
        switch (lineSplit.length) {
            case 0:  // If entire line/paragraph is link, 
                // TODO
                break;
            case 1:
                // TODO 
                break;
            case 2:  // If link is in between paragraph text,
                // TODO

                break;
            default: // probably not used?
                // TODO
                
        }
        if (lineSplit.length === 1) {
            if (lineSplit[0] === eachA.href) {
                // TODO
            } else {  // If link isn't in paragraph,
                // TODO if (inline link in paragraph) {} else if (no link in paragraph) {}
            }
        } else {  // If link is in paragraph

        }

        if (outLines[i] === eachA.href) {
            if (i > 0) { // If link is by itself, use the previous paragraph as the link
                result = toMdLink(outLines[i - 1], eachA.href);
                // TODO handle cases where the previous paragraph is also a link
            } else {
                result = eachA.href;
            }
        } else if (outLines[i].endsWith(eachA.href)) {
            // if link is at the end of a paragraph, use the paragraph as the link (TODO no, use last sentence?)
            result = toMdLink(outLines[i].substring(
                0, outLines[i].indexOf(eachA.href)).replace(":", ".").trim(), eachA.href
            );
        } else if (outLines[i].endsWith(eachA.href + ")")) {
            // TODO
        } else if (! txtToFind.includes(eachA.href)) {
            // inline links (?)
            result = txtLine.replace(txtToFind, toMdLink(txtToFind, eachA.href));
            // txtLine = outLines.filter(eachLine => eachLine.includes(txtToFind))[0].trim(); // old
        } else {
            // TODO add more conditions
        }
    }

    shredSrc = shred.hasAttribute("href") ? shred.href : shred.permalink; 
    return result + " ([via Reddit](https://reddit.com" + shredSrc + "))";

} // commentToMarkdown

// Save all Reddit posts and comments on the current page as Markdown text
postsMd = Array.from(document.getElementsByTagName("shreddit-post")).map(postToMarkdown);
commentsMd = Array.from(document.getElementsByTagName("shreddit-profile-comment")).map(commentToMarkdown); 